import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'web_deploy_env_stub.dart'
    if (dart.library.js_interop) 'web_deploy_env_web.dart' as web_deploy_env;

const _streamApiKeyOptional = bool.fromEnvironment(
  'STREAM_API_KEY_OPTIONAL',
  defaultValue: false,
);

/// [--dart-define=STREAM_API_KEY=...] required; web may fall back to `/env.json`.
Future<AppConfig> loadAppConfig() async {
  var config = AppConfig.fromEnvironment();
  if (kIsWeb && config.streamApiKey.isEmpty) {
    final deployedKey = await web_deploy_env.loadStreamApiKeyFromDeploy();
    if (deployedKey != null) {
      config = config.copyWith(streamApiKey: deployedKey);
    }
  }

  if (!_streamApiKeyOptional && config.streamApiKey.trim().isEmpty) {
    throw StateError(
      'STREAM_API_KEY is required. '
      'Pass --dart-define=STREAM_API_KEY=<GetStream public key>, '
      'or on web use web/env.json / deployed /env.json.',
    );
  }

  return config;
}
