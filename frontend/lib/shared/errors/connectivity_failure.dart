import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app_failure.dart';
import '../widgets/connectivity_snack_bar.dart';

final RegExp _httpStatusPrefix = RegExp(r'^HTTP \d+:');

/// Whether [exception] indicates no network or unreachable backend (not HTTP 4xx/5xx).
bool isConnectivityDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.unknown:
      return exception.response == null;
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
      return false;
  }
}

/// Whether [failure] should show [ConnectivitySnackBar] instead of a generic error snack bar.
bool isConnectivityFailure(AppFailure failure, {DioException? cause}) {
  if (cause != null && isConnectivityDioException(cause)) {
    return true;
  }
  if (failure is! NetworkFailure) {
    return false;
  }
  return !_httpStatusPrefix.hasMatch(failure.message);
}

/// Routes to connectivity snack bar or a generic error snack bar.
void showActionFailureSnackBar(
  BuildContext context,
  AppFailure failure, {
  DioException? cause,
}) {
  if (isConnectivityFailure(failure, cause: cause)) {
    ConnectivitySnackBar.show(context);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.message)));
  }
}
