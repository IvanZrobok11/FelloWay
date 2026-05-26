import 'package:web/web.dart' as web;

/// Reads OAuth BFF ticket from the real browser URL (not [Uri.base], which can lag on first frame).
String? bffTicketFromBrowser() {
  return Uri.parse(web.window.location.href).queryParameters['ticket'];
}

bool isCrossOriginApi(String apiBaseUrl) {
  final apiHost = Uri.tryParse(apiBaseUrl)?.host;
  if (apiHost == null || apiHost.isEmpty) {
    return false;
  }
  return apiHost != Uri.parse(web.window.location.href).host;
}
