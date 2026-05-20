import 'package:web/web.dart' as web;

void linkedInBffSignInWeb({
  required String apiBaseUrl,
  required String returnOrigin,
}) {
  final loginUri = Uri.parse(apiBaseUrl).replace(
    path: '/auth/linkedin/login',
    queryParameters: {
      'platform': 'web',
      'returnUrl': returnOrigin,
    },
  );
  web.window.location.href = loginUri.toString();
}
