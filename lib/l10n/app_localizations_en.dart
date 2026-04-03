// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FelloWay';

  @override
  String get tabEvents => 'Events';

  @override
  String get tabMap => 'Map';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get guestSignInPrompt => 'Sign in to continue';

  @override
  String get eventsPlaceholderTitle => 'Events';

  @override
  String get mapPlaceholderTitle => 'Map';

  @override
  String get chatsPlaceholderTitle => 'Chats';

  @override
  String get profilePlaceholderTitle => 'Profile';
}
