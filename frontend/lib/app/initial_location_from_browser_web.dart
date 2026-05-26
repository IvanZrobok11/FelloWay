import 'package:web/web.dart' as web;

/// Current path from the address bar (not [Uri.base], which can lag on first frame).
String? initialLocationFromBrowser() {
  final uri = Uri.parse(web.window.location.href);
  final path = uri.path;
  if (path.isEmpty || path == '/') {
    return null;
  }
  return path;
}
