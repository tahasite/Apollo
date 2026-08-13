import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';

class YoutubeService {
  static const List<String> _scopes = [YouTubeApi.youtubeUploadScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<bool> isSignedIn() async {
    return _googleSignIn.currentUser != null || await _googleSignIn.isSignedIn();
  }

  Future<String?> currentUserEmail() async {
    final user = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    return user?.email;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      throw Exception('google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<String> uploadShort({
    required String videoPath,
    required String title,
    required String description,
    required String tagsText,
    required String privacy,
    Function(double, String)? onProgress,
  }) async {
    if (onProgress != null) onProgress(0.02, 'signing in to youtube...');
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    account ??= await _googleSignIn.signIn();
    if (account == null) throw Exception('sign in cancelled');

    if (onProgress != null) onProgress(0.05, 'connecting to youtube api...');
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) throw Exception('could not get authenticated client');

    final youtube = YouTubeApi(httpClient);

    final tags = tagsText.replaceAll(',', ' ').split(RegExp(r'\s+')).map((t) => t.replaceFirst('#', '').trim()).where((t) => t.isNotEmpty).toList();

    final video = Video(
      snippet: VideoSnippet(
        title: title.length > 100 ? title.substring(0, 100) : title,
        description: description,
        tags: tags.take(30).toList(),
        categoryId: '17',
      ),
      status: VideoStatus(
        privacyStatus: privacy,
        selfDeclaredMadeForKids: false,
        madeForKids: false,
      ),
    );

    final file = File(videoPath);
    final fileLength = await file.length();
    final media = Media(file.openRead(), fileLength, contentType: 'video/mp4');

    if (onProgress != null) onProgress(0.1, 'starting upload...');

    final response = await youtube.videos.insert(
      video,
      ['snippet', 'status'],
      uploadMedia: media,
      uploadOptions: ResumableUploadOptions(),
    );

    if (onProgress != null) onProgress(1.0, 'upload complete: ${response.id}');
    return response.id ?? 'unknown';
  }
}