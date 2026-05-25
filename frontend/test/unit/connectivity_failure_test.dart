import 'package:dio/dio.dart';
import 'package:felloway_client/shared/errors/app_failure.dart';
import 'package:felloway_client/shared/errors/connectivity_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isConnectivityDioException', () {
    test('connectionError is connectivity', () {
      expect(
        isConnectivityDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          ),
        ),
        isTrue,
      );
    });

    test('connectionTimeout is connectivity', () {
      expect(
        isConnectivityDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isTrue,
      );
    });

    test('badResponse is not connectivity', () {
      expect(
        isConnectivityDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 500,
            ),
          ),
        ),
        isFalse,
      );
    });

    test('unknown without response is connectivity', () {
      expect(
        isConnectivityDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.unknown,
          ),
        ),
        isTrue,
      );
    });
  });

  group('isConnectivityFailure', () {
    test('NetworkFailure without HTTP prefix is connectivity', () {
      expect(
        isConnectivityFailure(const NetworkFailure('Connection refused')),
        isTrue,
      );
    });

    test('NetworkFailure with HTTP status is not connectivity', () {
      expect(
        isConnectivityFailure(const NetworkFailure('HTTP 403: Forbidden')),
        isFalse,
      );
    });

    test('AuthFailure is not connectivity', () {
      expect(isConnectivityFailure(const AuthFailure('Unauthorized')), isFalse);
    });

    test('uses Dio cause when provided', () {
      expect(
        isConnectivityFailure(
          const NetworkFailure('HTTP 500: Server error'),
          cause: DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          ),
        ),
        isTrue,
      );
    });
  });
}
