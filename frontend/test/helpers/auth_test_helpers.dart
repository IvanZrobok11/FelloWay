import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/features/auth/application/auth_completion_service.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/domain/web_auth_mode.dart';

AuthCompletionService testAuthCompletion({
  required AuthApi authApi,
  required AuthSession authSession,
  WebAuthMode webAuthMode = WebAuthMode.sameOriginCookie,
}) {
  return AuthCompletionService(
    authApi: authApi,
    authSession: authSession,
    webAuthMode: webAuthMode,
  );
}
