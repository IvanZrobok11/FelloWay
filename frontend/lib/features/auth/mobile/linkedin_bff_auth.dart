import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Result of mobile BFF LinkedIn sign-in (custom scheme callback only).
sealed class LinkedInBffMobileResult {}

final class LinkedInBffMobileTicket extends LinkedInBffMobileResult {
  LinkedInBffMobileTicket(this.ticket);

  final String ticket;
}

final class LinkedInBffMobileError extends LinkedInBffMobileResult {
  LinkedInBffMobileError(this.message);

  final String message;
}

final class LinkedInBffMobileCancelled extends LinkedInBffMobileResult {}

/// Opens API BFF login in a secure browser session (iOS/Android only).
Future<LinkedInBffMobileResult> linkedInBffSignInMobile({
  required String apiBaseUrl,
}) async {
  if (kIsWeb) {
    throw StateError('linkedin_bff_auth is mobile-only');
  }

  final loginUri = Uri.parse(apiBaseUrl).replace(
    path: '/auth/linkedin/login',
    queryParameters: {
      'platform': 'mobile',
    },
  );

  try {
    final result = await FlutterWebAuth2.authenticate(
      url: loginUri.toString(),
      callbackUrlScheme: 'com.felloway.app',
    );
    return _parseCallback(Uri.parse(result));
  } on Exception catch (e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('canceled') || msg.contains('cancelled')) {
      return LinkedInBffMobileCancelled();
    }
    return LinkedInBffMobileError(e.toString());
  }
}

LinkedInBffMobileResult _parseCallback(Uri uri) {
  if (uri.host != 'auth' || !uri.path.startsWith('/callback')) {
    return LinkedInBffMobileError('unexpected_callback');
  }

  final error = uri.queryParameters['error'];
  if (error != null && error.isNotEmpty) {
    return LinkedInBffMobileError(error);
  }

  final ticket = uri.queryParameters['ticket'];
  if (ticket == null || ticket.isEmpty) {
    return LinkedInBffMobileError('missing_ticket');
  }

  return LinkedInBffMobileTicket(ticket);
}
