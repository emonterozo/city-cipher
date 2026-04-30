import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class LinkService {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openMaps(double lat, double lng) async {
    Uri uri;

    if (Platform.isIOS) {
      final googleMapsUrl = Uri.parse("comgooglemaps://?q=$lat,$lng");
      final appleMapsUrl = Uri.parse("http://maps.apple.com/?q=$lat,$lng");

      if (await canLaunchUrl(googleMapsUrl)) {
        uri = googleMapsUrl;
      } else {
        uri = appleMapsUrl;
      }
    } else {
      uri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
