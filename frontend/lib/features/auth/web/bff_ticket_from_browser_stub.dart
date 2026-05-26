/// Non-web: [Uri.base] is sufficient.
String? bffTicketFromBrowser() => Uri.base.queryParameters['ticket'];

/// Reads BFF ticket from browser URL first, then [uri] or [Uri.base].
String? readBffTicket({Uri? uri}) {
  final fromBrowser = bffTicketFromBrowser();
  if (fromBrowser != null && fromBrowser.isNotEmpty) {
    return fromBrowser;
  }
  final ticket =
      uri?.queryParameters['ticket'] ?? Uri.base.queryParameters['ticket'];
  if (ticket != null && ticket.isNotEmpty) {
    return ticket;
  }
  return null;
}

bool isCrossOriginApi(String apiBaseUrl) {
  final apiHost = Uri.tryParse(apiBaseUrl)?.host;
  if (apiHost == null || apiHost.isEmpty) {
    return false;
  }
  return apiHost != Uri.base.host;
}
