import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SharingService {
  static const String appStoreUrl =
      'https://apps.apple.com/app/ridenow'; // Placeholder
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ridenow.app'; // Placeholder
  static const String baseWebUrl =
      'https://ridenow-web.vercel.app/watch'; // Placeholder landing page

  Future<void> shareRide(String rideId, {String? platform}) async {
    final String deepLink = 'ridenow://watch/$rideId';
    final String webFallback = '$baseWebUrl/$rideId';

    // In a real app, we'd use Firebase Dynamic Links or a redirection service.
    // Here we'll share a message that includes the link.
    final String message =
        "Watch my ride on RideNow: $webFallback\n\nDeep Link: $deepLink";

    switch (platform) {
      case 'facebook':
        // Facebook sharing usually works better with a URL
        await _launchUrl(
          'https://www.facebook.com/sharer/sharer.php?u=$webFallback',
        );
        break;
      case 'snapchat':
        // Snapchat usually requires their SDK, but we can try sharing the link
        await Share.share(message);
        break;
      case 'whatsapp':
        await _launchUrl(
          'whatsapp://send?text=${Uri.encodeComponent(message)}',
        );
        break;
      default:
        await Share.share(message);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
