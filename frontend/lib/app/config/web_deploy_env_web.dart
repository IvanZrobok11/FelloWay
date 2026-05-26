import 'package:dio/dio.dart';

/// Loaded from `/env.json` on the web host (written by CI deploy to S3).
Future<String?> loadStreamApiKeyFromDeploy() async {
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: Uri.base.origin,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final response = await dio.get<Map<String, dynamic>>('/env.json');
    if (response.statusCode != 200) {
      return null;
    }
    final key = response.data?['streamApiKey'] as String?;
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  } on Object {
    return null;
  }
}
