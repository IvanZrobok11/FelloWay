import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Web-only: load key from `env.json` (local `web/env.json` or deploy fallback).
Future<String?> loadStreamApiKeyFromDeploy() async {
  try {
    final uri = Uri.base.resolve('env.json');
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        responseType: ResponseType.plain,
        headers: const {'Cache-Control': 'no-cache'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final response = await dio.get<String>(uri.toString());
    if (response.statusCode != 200) {
      return null;
    }
    final body = response.data;
    if (body == null || body.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      return null;
    }
    final raw = decoded['STREAM_API_KEY'] ?? decoded['streamApiKey'];
    if (raw is! String || raw.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('env.json: missing STREAM_API_KEY');
      }
      return null;
    }
    return raw.trim();
  } on Object catch (e, st) {
    if (kDebugMode) {
      debugPrint('env.json load failed: $e\n$st');
    }
    return null;
  }
}
