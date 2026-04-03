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
  String get commonCancel => 'Скасувати';

  @override
  String get commonErrorTitle => 'Щось пішло не так';

  @override
  String get emptyStateTitle => 'Поки що порожньо';

  @override
  String get guestSignInPrompt => 'Увійдіть, щоб продовжити';

  @override
  String get signInTitle => 'Увійти';

  @override
  String get signInSubtitle => 'Продовжити через LinkedIn або Facebook.';

  @override
  String get oauthLinkedIn => 'Продовжити з LinkedIn';

  @override
  String get oauthFacebook => 'Продовжити з Facebook';

  @override
  String get demoSignIn => 'Демо-вхід (debug)';

  @override
  String get oauthNotConfigured =>
      'OAuth не налаштовано. Задайте OAUTH_* у dart-define.';

  @override
  String get oauthMissingTokens => 'Токен доступу не отримано.';

  @override
  String oauthFailed(Object message) {
    return 'Помилка входу: $message';
  }

  @override
  String get onboardingWelcomeTitle => 'Ласкаво просимо';

  @override
  String get onboardingWelcomeBody =>
      'FelloWay допомагає нетворкитися перед IT-конференціями та домовлятися про спільні поїздки.';

  @override
  String get onboardingContinue => 'Далі';

  @override
  String get onboardingNameTitle => 'Ваше ім\'я';

  @override
  String get onboardingNameLabel => 'Ім\'я або нікнейм';

  @override
  String get onboardingInterestsTitle => 'Інтереси та хобі';

  @override
  String get onboardingInterestsSection => 'Професійні інтереси';

  @override
  String get onboardingHobbiesSection => 'Хобі';

  @override
  String get onboardingHobbiesLabel => 'Що вам подобається?';

  @override
  String get onboardingCityTitle => 'Місто проживання';

  @override
  String get onboardingCityLabel => 'Місто';

  @override
  String get onboardingGoToEvents => 'До подій';

  @override
  String onboardingSaveFailed(Object message) {
    return 'Не вдалося зберегти профіль: $message';
  }

  @override
  String get eventsScreenTitle => 'Події';

  @override
  String get eventsSearchHint => 'Пошук за назвою, тегом або містом';

  @override
  String get eventCardGuestHint => 'Увійдіть, щоб побачити, хто ще їде.';

  @override
  String get eventCardAttendeeTeaser => 'Також їдуть:';

  @override
  String get eventJoin => 'Йду';

  @override
  String get eventLeave => 'Скасувати участь';

  @override
  String get eventJoinSignIn => 'Увійти, щоб приєднатися';

  @override
  String get eventParticipantsTitle => 'Учасники';

  @override
  String get eventGuestBlurHint => 'Увійдіть, щоб побачити учасників.';

  @override
  String eventSchedule(Object start, Object end) {
    return '$start – $end';
  }

  @override
  String eventCapacity(Object count) {
    return 'Місць: $count';
  }

  @override
  String eventPrice(Object price) {
    return 'Ціна: $price';
  }

  @override
  String get eventOfficialLink => 'Офіційний сайт';

  @override
  String get mapScreenTitle => 'Карта';

  @override
  String get mapDiscoveryHint =>
      'Перегляд подій за інтересами. Повноцінну карту можна увімкнути з ключем maps API.';

  @override
  String get mapFilterAll => 'Усі';

  @override
  String get profileScreenTitle => 'Профіль';

  @override
  String get profileGuestMessage => 'Увійдіть, щоб переглянути профіль.';

  @override
  String get profileSignOut => 'Вийти';

  @override
  String profileRating(Object value) {
    return 'Рейтинг: $value';
  }

  @override
  String get profileLinkedIn => 'LinkedIn';

  @override
  String get profileFacebook => 'Facebook';

  @override
  String get profileInterests => 'Інтереси';

  @override
  String get profileHobbies => 'Хобі';

  @override
  String get chatsGuestMessage => 'Увійдіть, щоб побачити чати.';

  @override
  String get eventsPlaceholderTitle => 'Події';

  @override
  String get mapPlaceholderTitle => 'Карта';

  @override
  String get chatsPlaceholderTitle => 'Чати';

  @override
  String get profilePlaceholderTitle => 'Профіль';
}
