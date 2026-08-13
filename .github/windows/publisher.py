import os
import json
import time
import threading
import requests
import subprocess
import shutil
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TOKENS_DIR = os.path.join(BASE_DIR, "tokens")
YOUTUBE_SECRET_FILE = os.path.join(BASE_DIR, "youtube_client_secret.json")
YOUTUBE_TOKEN_FILE = os.path.join(TOKENS_DIR, "youtube_token.json")

os.makedirs(TOKENS_DIR, exist_ok=True)


class CloudinaryUploader:
    def __init__(self, cloud_name, api_key, api_secret):
        import cloudinary
        import cloudinary.uploader
        import cloudinary.api
        cloudinary.config(
            cloud_name=cloud_name,
            api_key=api_key,
            api_secret=api_secret,
            secure=True
        )
        self.cloudinary = cloudinary
        self.uploader = cloudinary.uploader
        self.api = cloudinary.api

    def upload_video(self, video_path, progress_callback=None):
        if progress_callback:
            progress_callback(0.15, "uploading video to cloudinary...")

        public_id = f"sve_reel_{int(time.time())}"

        result = self.uploader.upload_large(
            video_path,
            resource_type="video",
            public_id=public_id,
            folder="sve_uploads",
            chunk_size=6000000,
            timeout=600
        )

        secure_url = result.get("secure_url", "")
        returned_public_id = result.get("public_id", "")

        if not secure_url:
            raise RuntimeError(f"cloudinary upload failed. full response: {result}")

        return {
            "url": secure_url,
            "public_id": returned_public_id
        }

    def delete_video(self, public_id):
        try:
            self.uploader.destroy(public_id, resource_type="video", invalidate=True)
            return True
        except:
            return False


class InstagramPublisher:
    def __init__(self, access_token, user_id, app_secret):
        self.token = access_token
        self.user_id = user_id
        self.app_secret = app_secret
        self.api_base = "https://graph.instagram.com"

    def exchange_to_long_lived(self):
        cached_file = os.path.join(TOKENS_DIR, "instagram_long_token.json")
        if os.path.exists(cached_file):
            try:
                with open(cached_file, "r") as f:
                    cached = json.load(f)
                if cached.get("short_token") == self.token and cached.get("long_token"):
                    self.token = cached["long_token"]
                    return
            except:
                pass

        url = f"{self.api_base}/access_token"
        params = {
            "grant_type": "ig_exchange_token",
            "client_secret": self.app_secret,
            "access_token": self.token
        }
        response = requests.get(url, params=params, timeout=30)
        data = response.json()
        if "access_token" in data:
            long_token = data["access_token"]
            with open(cached_file, "w") as f:
                json.dump({
                    "short_token": self.token,
                    "long_token": long_token,
                    "created_at": datetime.now().isoformat()
                }, f, indent=4)
            self.token = long_token

    def _request_with_retry(self, method, url, max_retries=5, **kwargs):
        last_error = None
        for attempt in range(max_retries):
            try:
                if method.lower() == "get":
                    response = requests.get(url, timeout=30, **kwargs)
                else:
                    response = requests.post(url, timeout=60, **kwargs)
                return response
            except Exception as e:
                last_error = str(e)
                time.sleep(3 + attempt * 2)
        raise RuntimeError(f"network request failed after {max_retries} attempts. last error: {last_error}")

    def verify_token(self):
        try:
            self.exchange_to_long_lived()
        except:
            pass

        url = f"{self.api_base}/me"
        params = {
            "fields": "id,username,account_type",
            "access_token": self.token
        }
        response = self._request_with_retry("get", url, params=params)
        data = response.json()
        if "error" in data:
            raise RuntimeError(f"instagram token error: {data['error'].get('message', str(data['error']))}")
        return data

    def create_reel_container(self, video_url, caption):
        url = f"{self.api_base}/{self.user_id}/media"
        payload = {
            "media_type": "REELS",
            "video_url": video_url,
            "caption": caption,
            "share_to_feed": "true",
            "access_token": self.token
        }
        response = self._request_with_retry("post", url, data=payload)
        data = response.json()
        if "error" in data:
            raise RuntimeError(f"instagram container error: {data['error'].get('message', str(data['error']))}")
        container_id = data.get("id")
        if not container_id:
            raise RuntimeError(f"no container id returned: {data}")
        return container_id

    def wait_for_container_ready(self, container_id, max_wait=600, poll_interval=8):
        url = f"{self.api_base}/{container_id}"
        deadline = time.time() + max_wait
        consecutive_errors = 0
        last_error = None
        while time.time() < deadline:
            try:
                params = {
                    "fields": "status_code,status,id",
                    "access_token": self.token
                }
                response = requests.get(url, params=params, timeout=30)
                data = response.json()
                status_code = data.get("status_code", "")
                status_detail = data.get("status", "")
                consecutive_errors = 0
                if status_code == "FINISHED":
                    return True
                if status_code in ["ERROR", "EXPIRED"]:
                    raise RuntimeError(f"instagram rejected the video.\nstatus_code: {status_code}\nreason: {status_detail}")
            except RuntimeError:
                raise
            except Exception as e:
                consecutive_errors += 1
                last_error = str(e)
                if consecutive_errors >= 5:
                    raise RuntimeError(f"instagram polling failed 5 times in a row. last error: {last_error}")
            time.sleep(poll_interval)
        raise RuntimeError(f"instagram container did not finish within {max_wait} seconds.")

    def publish_container(self, container_id):
        url = f"{self.api_base}/{self.user_id}/media_publish"
        payload = {
            "creation_id": container_id,
            "access_token": self.token
        }
        response = self._request_with_retry("post", url, data=payload)
        data = response.json()
        if "error" in data:
            raise RuntimeError(f"instagram publish error: {data['error'].get('message', str(data['error']))}")
        media_id = data.get("id")
        if not media_id:
            raise RuntimeError(f"no media id returned after publish: {data}")
        return media_id

    def publish_reel(self, video_path, caption, cloud_name, cloud_api_key, cloud_api_secret, progress_callback=None, delete_after_publish=True):
        if progress_callback:
            progress_callback(0.05, "verifying instagram token...")
        self.verify_token()

        if progress_callback:
            progress_callback(0.1, "preparing cloudinary upload...")

        uploader = CloudinaryUploader(cloud_name, cloud_api_key, cloud_api_secret)
        upload_result = uploader.upload_video(video_path, progress_callback=progress_callback)
        video_url = upload_result["url"]
        cloud_public_id = upload_result["public_id"]

        if progress_callback:
            progress_callback(0.4, f"cloudinary ready. creating instagram reel container...")

        try:
            container_id = self.create_reel_container(video_url, caption)

            if progress_callback:
                progress_callback(0.5, f"container created ({container_id}). waiting for instagram to process video...")

            self.wait_for_container_ready(container_id, max_wait=600, poll_interval=8)

            if progress_callback:
                progress_callback(0.9, "video processed. publishing reel...")

            media_id = self.publish_container(container_id)

            if progress_callback:
                progress_callback(1.0, f"instagram reel published successfully. media id: {media_id}")

            if delete_after_publish:
                uploader.delete_video(cloud_public_id)

            return media_id
        except Exception:
            if delete_after_publish:
                uploader.delete_video(cloud_public_id)
            raise


class YouTubePublisher:
    def __init__(self, client_id=None, client_secret=None):
        self.credentials = None
        self.client_id = client_id or ""
        self.client_secret = client_secret or ""
        self.scopes = ["https://www.googleapis.com/auth/youtube.upload"]

    def _load_credentials(self):
        from google.oauth2.credentials import Credentials
        from google.auth.transport.requests import Request

        if os.path.exists(YOUTUBE_TOKEN_FILE):
            try:
                with open(YOUTUBE_TOKEN_FILE, "r") as f:
                    token_data = json.load(f)
                creds = Credentials(
                    token=token_data.get("token"),
                    refresh_token=token_data.get("refresh_token"),
                    token_uri="https://oauth2.googleapis.com/token",
                    client_id=self.client_id,
                    client_secret=self.client_secret,
                    scopes=self.scopes
                )
                if creds.expired and creds.refresh_token:
                    creds.refresh(Request())
                    self._save_credentials(creds)
                if creds.valid:
                    return creds
            except Exception:
                pass
        return None

    def _save_credentials(self, creds):
        token_data = {
            "token": creds.token,
            "refresh_token": creds.refresh_token,
            "token_uri": creds.token_uri,
            "client_id": creds.client_id,
            "client_secret": creds.client_secret,
            "scopes": list(creds.scopes) if creds.scopes else self.scopes
        }
        with open(YOUTUBE_TOKEN_FILE, "w") as f:
            json.dump(token_data, f, indent=4)

    def authenticate(self, progress_callback=None):
        from google_auth_oauthlib.flow import InstalledAppFlow

        if not os.path.exists(YOUTUBE_SECRET_FILE):
            raise RuntimeError(f"youtube client secret file not found at:\n{YOUTUBE_SECRET_FILE}")

        creds = self._load_credentials()
        if creds:
            self.credentials = creds
            return True

        if progress_callback:
            progress_callback(0.1, "opening browser for youtube authentication...")

        flow = InstalledAppFlow.from_client_secrets_file(
            YOUTUBE_SECRET_FILE,
            scopes=self.scopes
        )
        creds = flow.run_local_server(
            port=0,
            prompt="consent",
            authorization_prompt_message="please complete the authentication in your browser."
        )
        self._save_credentials(creds)
        self.credentials = creds
        return True

    def is_authenticated(self):
        creds = self._load_credentials()
        return creds is not None and creds.valid

    def revoke_token(self):
        if os.path.exists(YOUTUBE_TOKEN_FILE):
            os.remove(YOUTUBE_TOKEN_FILE)

    def upload_short(self, video_path, title, description, tags_text, privacy="private", progress_callback=None):
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload

        if not self.credentials:
            self.authenticate(progress_callback)

        if progress_callback:
            progress_callback(0.1, "connecting to youtube api...")

        youtube = build("youtube", "v3", credentials=self.credentials)

        tags = []
        for raw in tags_text.replace(",", " ").split():
            tag = raw.strip().lstrip("#")
            if tag:
                tags.append(tag)

        body = {
            "snippet": {
                "title": title[:100],
                "description": description,
                "tags": tags[:30],
                "categoryId": "17"
            },
            "status": {
                "privacyStatus": privacy,
                "selfDeclaredMadeForKids": False,
                "madeForKids": False
            }
        }

        media = MediaFileUpload(
            video_path,
            mimetype="video/mp4",
            resumable=True,
            chunksize=5 * 1024 * 1024
        )

        if progress_callback:
            progress_callback(0.15, "starting youtube upload...")

        request = youtube.videos().insert(
            part="snippet,status",
            body=body,
            media_body=media
        )

        response = None
        while response is None:
            status, response = request.next_chunk()
            if status:
                upload_progress = 0.15 + (status.progress() * 0.80)
                if progress_callback:
                    progress_callback(upload_progress, f"uploading to youtube... {int(status.progress() * 100)}%")

        video_id = response.get("id", "")

        if progress_callback:
            progress_callback(1.0, f"youtube upload complete. video id: {video_id}")

        return video_id