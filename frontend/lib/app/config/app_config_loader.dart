import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'web_deploy_env_stub.dart'
    if (dart.library.html) 'web_deploy_env_web.dart' as web_deploy_env;

/// Compile-time [--dart-define] plus optional web `/env.json` from deploy.
Future<AppConfig> loadAppConfig() async {
  final config = AppConfig.fromEnvironment();
  if (!kIsWeb || config.streamApiKey.isNotEmpty) {
    return config;
  }

  final deployedKey = await web_deploy_env.loadStreamApiKeyFromDeploy();
  if (deployedKey == null) {
    return config;
  }

  return config.copyWith(streamApiKey: deployedKey);
}
