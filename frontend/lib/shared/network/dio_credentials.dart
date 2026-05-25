import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dio_credentials_stub.dart'
    if (dart.library.html) 'dio_credentials_web.dart' as impl;

void configureDioCredentials(Dio dio, {required bool enabled}) {
  if (!kIsWeb || !enabled) {
    return;
  }
  impl.configureDioCredentials(dio);
}
