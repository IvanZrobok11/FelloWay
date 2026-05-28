import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrl(String url) async {
  final normalized = url.contains('://') ? url : 'https://$url';
  final uri = Uri.tryParse(normalized);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
