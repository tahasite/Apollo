import 'package:dio/dio.dart';

class IpInfo {
  final String ip;
  final String country;
  final String countryCode;
  final String city;
  final String isp;
  final String flag;

  IpInfo({
    required this.ip,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.isp,
    required this.flag,
  });
}

class IpService {
  static const Map<String, String> _flags = {
    'AF': '🇦🇫', 'AL': '🇦🇱', 'DZ': '🇩🇿', 'AR': '🇦🇷', 'AM': '🇦🇲',
    'AU': '🇦🇺', 'AT': '🇦🇹', 'AZ': '🇦🇿', 'BH': '🇧🇭', 'BD': '🇧🇩',
    'BY': '🇧🇾', 'BE': '🇧🇪', 'BR': '🇧🇷', 'BG': '🇧🇬', 'CA': '🇨🇦',
    'CL': '🇨🇱', 'CN': '🇨🇳', 'CO': '🇨🇴', 'HR': '🇭🇷', 'CY': '🇨🇾',
    'CZ': '🇨🇿', 'DK': '🇩🇰', 'EG': '🇪🇬', 'EE': '🇪🇪', 'FI': '🇫🇮',
    'FR': '🇫🇷', 'GE': '🇬🇪', 'DE': '🇩🇪', 'GR': '🇬🇷', 'HK': '🇭🇰',
    'HU': '🇭🇺', 'IN': '🇮🇳', 'ID': '🇮🇩', 'IR': '🇮🇷', 'IQ': '🇮🇶',
    'IE': '🇮🇪', 'IL': '🇮🇱', 'IT': '🇮🇹', 'JP': '🇯🇵', 'JO': '🇯🇴',
    'KZ': '🇰🇿', 'KE': '🇰🇪', 'KR': '🇰🇷', 'KW': '🇰🇼', 'LB': '🇱🇧',
    'LY': '🇱🇾', 'MY': '🇲🇾', 'MX': '🇲🇽', 'MA': '🇲🇦', 'NL': '🇳🇱',
    'NZ': '🇳🇿', 'NG': '🇳🇬', 'NO': '🇳🇴', 'OM': '🇴🇲', 'PK': '🇵🇰',
    'PS': '🇵🇸', 'PA': '🇵🇦', 'PE': '🇵🇪', 'PH': '🇵🇭', 'PL': '🇵🇱',
    'PT': '🇵🇹', 'QA': '🇶🇦', 'RO': '🇷🇴', 'RU': '🇷🇺', 'SA': '🇸🇦',
    'RS': '🇷🇸', 'SG': '🇸🇬', 'SK': '🇸🇰', 'SI': '🇸🇮', 'ZA': '🇿🇦',
    'ES': '🇪🇸', 'SE': '🇸🇪', 'CH': '🇨🇭', 'SY': '🇸🇾', 'TW': '🇹🇼',
    'TH': '🇹🇭', 'TR': '🇹🇷', 'UA': '🇺🇦', 'AE': '🇦🇪', 'GB': '🇬🇧',
    'US': '🇺🇸', 'UY': '🇺🇾', 'UZ': '🇺🇿', 'VE': '🇻🇪', 'VN': '🇻🇳',
    'YE': '🇾🇪',
  };

  static Future<IpInfo> getInfo() async {
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)));
      final response = await dio.get('http://ip-api.com/json/?fields=query,country,countryCode,city,isp');
      final data = response.data as Map;
      final code = data['countryCode']?.toString() ?? '';
      return IpInfo(
        ip: data['query']?.toString() ?? 'unknown',
        country: data['country']?.toString() ?? 'unknown',
        countryCode: code,
        city: data['city']?.toString() ?? '',
        isp: data['isp']?.toString() ?? '',
        flag: _flags[code] ?? '🏳️',
      );
    } catch (_) {
      return IpInfo(ip: 'unknown', country: 'unknown', countryCode: '', city: '', isp: '', flag: '🏳️');
    }
  }
}