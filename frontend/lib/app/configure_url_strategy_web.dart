import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Use path URLs (`/sign-in`) so OAuth redirects from the backend keep [?code=] in sync with [GoRouter].
void configureWebUrlStrategy() {
  usePathUrlStrategy();
}
