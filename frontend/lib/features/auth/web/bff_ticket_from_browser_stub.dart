/// Non-web: [Uri.base] is sufficient.
String? bffTicketFromBrowser() => Uri.base.queryParameters['ticket'];

bool isCrossOriginApi(String apiBaseUrl) {
  final apiHost = Uri.tryParse(apiBaseUrl)?.host;
  if (apiHost == null || apiHost.isEmpty) {
    return false;
  }
  return apiHost != Uri.base.host;
}
