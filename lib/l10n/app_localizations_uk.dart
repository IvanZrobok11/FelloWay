// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'FelloWay';

  @override
  String get tabEvents => 'Події';

  @override
  String get tabMap => 'Карта';

  @override
  String get tabChats => 'Чати';

  @override
  String get tabProfile => 'Профіль';

  @override
  String get commonLoading => 'Завантаження…';

  @override
  String get commonRetry => 'Повторити';

  @override
  String get commonErrorTitle => 'Щось пішло не так';

  @override
  String get emptyStateTitle => 'Поки що порожньо';

  @override
  String get guestSignInPrompt => 'Увійдіть, щоб продовжити';

  @override
  String get eventsPlaceholderTitle => 'Події';

  @override
  String get mapPlaceholderTitle => 'Карта';

  @override
  String get chatsPlaceholderTitle => 'Чати';

  @override
  String get profilePlaceholderTitle => 'Профіль';
}
