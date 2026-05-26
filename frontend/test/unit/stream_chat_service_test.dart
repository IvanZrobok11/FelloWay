import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty streamApiKey yields missingApiKey without backend token call', () async {
    SharedPreferences.setMockInitialValues({});
    const config = AppConfig(
      apiBaseUrl: 'https://api.test.local',
      streamApiKey: '',
    );
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final usersRepository = UsersRepository(apiClient, config);
    final service = StreamChatService(config: config, apiClient: apiClient);

    await service.syncWithSession(
      isAuthenticated: true,
      usersRepository: usersRepository,
    );

    expect(service.status, StreamChatConnectStatus.missingApiKey);
  });
}
