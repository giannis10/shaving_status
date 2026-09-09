import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdaterService {
  static const String _repoUrl = 'https://api.github.com/repos/giannis10/shaving_status/releases/latest';
  static const String _releasesUrl = 'https://github.com/giannis10/shaving_status/releases/latest';

  /// Ελέγχει αν υπάρχει νεότερη έκδοση στο GitHub Releases
  static Future<Map<String, dynamic>> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_repoUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['tag_name']; // π.χ. 'v1.0.1'
        
        // Αφαιρούμε το 'v' αν υπάρχει
        if (latestVersion.startsWith('v') || latestVersion.startsWith('V')) {
          latestVersion = latestVersion.substring(1);
        }

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version; // π.χ. '1.0.0'

        // Απλή σύγκριση εκδόσεων (π.χ. '1.0.1' > '1.0.0')
        final bool hasUpdate = _isVersionGreater(latestVersion, currentVersion);
        return {
          'hasUpdate': hasUpdate,
          'releaseNotes': data['body'] ?? '',
        };
      }
    } catch (e) {
      print('Update check failed: $e');
    }
    return {'hasUpdate': false, 'releaseNotes': ''};
  }

  /// Ανοίγει τον browser στη σελίδα των releases του GitHub
  static Future<void> launchUpdateUrl() async {
    final Uri url = Uri.parse(_releasesUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $_releasesUrl');
    }
  }

  /// True αν η v1 > v2
  static bool _isVersionGreater(String v1, String v2) {
    List<int> parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int p1 = i < parts1.length ? parts1[i] : 0;
      int p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 > p2) return true;
      if (p1 < p2) return false;
    }
    return false;
  }
}
