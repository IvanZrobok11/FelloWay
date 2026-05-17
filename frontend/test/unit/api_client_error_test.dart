import 'package:dio/dio.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/shared/errors/app_failure.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapDioError uses ErrorResponse message', () {
    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: '',
    );
    final client = ApiClient(config: config, tokenStorage: TokenStorage());
    final failure = client.mapDioError(
      DioException(
        requestOptions: RequestOptions(path: '/users/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/users/me'),
          statusCode: 400,
          data: {
            'code': 'validation_failed',
            'message': 'Invalid profile',
            'details': [
              {'field': 'displayName', 'message': 'Too long'},
            ],
          },
        ),
        type: DioExceptionType.badResponse,
      ),
    );
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, contains('Too long'));
  });
}
