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
  String get commonCancel => 'Cancel';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get guestSignInPrompt => 'Sign in to continue';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Use LinkedIn or Facebook to continue.';

  @override
  String get oauthLinkedIn => 'Continue with LinkedIn';

  @override
  String get oauthFacebook => 'Continue with Facebook';

  @override
  String get demoSignIn => 'Demo sign-in (debug)';

  @override
  String get oauthNotConfigured =>
      'OAuth is not configured. Set OAUTH_* dart-define values.';

  @override
  String get oauthMissingTokens => 'No access token returned.';

  @override
  String oauthFailed(Object message) {
    return 'Sign-in failed: $message';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeBody =>
      'FelloWay helps you network before IT conferences and coordinate rides.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingNameTitle => 'Your name';

  @override
  String get onboardingNameLabel => 'Name or nickname';

  @override
  String get onboardingInterestsTitle => 'Interests and hobbies';

  @override
  String get onboardingInterestsSection => 'Professional interests';

  @override
  String get onboardingHobbiesSection => 'Hobbies';

  @override
  String get onboardingHobbiesLabel => 'What do you enjoy?';

  @override
  String get onboardingCityTitle => 'Home city';

  @override
  String get onboardingCityLabel => 'City';

  @override
  String get onboardingGoToEvents => 'Go to events';

  @override
  String onboardingSaveFailed(Object message) {
    return 'Could not save profile: $message';
  }

  @override
  String get eventsScreenTitle => 'Events';

  @override
  String get eventsSearchHint => 'Search by name, tag, or city';

  @override
  String get eventCardGuestHint => 'Sign in to see who else is going.';

  @override
  String get eventCardAttendeeTeaser => 'People also attending:';

  @override
  String get eventJoin => 'I\'m going';

  @override
  String get eventLeave => 'Cancel attendance';

  @override
  String get eventJoinSignIn => 'Sign in to join';

  @override
  String get eventParticipantsTitle => 'Participants';

  @override
  String get eventGuestBlurHint => 'Sign in to see participants.';

  @override
  String eventSchedule(Object start, Object end) {
    return '$start – $end';
  }

  @override
  String eventCapacity(Object count) {
    return 'Capacity: $count';
  }

  @override
  String eventPrice(Object price) {
    return 'Price: $price';
  }

  @override
  String get eventOfficialLink => 'Official website';

  @override
  String get mapScreenTitle => 'Map';

  @override
  String get mapDiscoveryHint =>
      'Browse events by interest. Full map tiles can be enabled with a maps API key.';

  @override
  String get mapFilterAll => 'All';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get profileGuestMessage => 'Sign in to view your profile.';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String profileRating(Object value) {
    return 'Rating: $value';
  }

  @override
  String get profileLinkedIn => 'LinkedIn';

  @override
  String get profileFacebook => 'Facebook';

  @override
  String get profileInterests => 'Interests';

  @override
  String get profileHobbies => 'Hobbies';

  @override
  String get chatsGuestMessage => 'Sign in to see your chats.';

  @override
  String get chatsStreamKeyHint =>
      'Set STREAM_API_KEY to enable GetStream chat.';

  @override
  String get chatsConnecting => 'Connecting to chat…';

  @override
  String get chatsDemoHint =>
      'Demo API: chat uses GetStream only with a real backend token.';

  @override
  String chatsLoadError(Object message) {
    return 'Could not load chats: $message';
  }

  @override
  String get chatOpenEventChat => 'Event chat';

  @override
  String get chatMessageUser => 'Message';

  @override
  String get chatChannelTitle => 'Chat';

  @override
  String get chatDmReadOnlyHint =>
      'You left this event — messages are read-only.';

  @override
  String get chatReportTitle => 'Report';

  @override
  String get chatReportDetailsLabel => 'What happened?';

  @override
  String get chatReportSubmitted => 'Thanks — we will review this report.';

  @override
  String get chatReportSubmit => 'Submit report';

  @override
  String get chatBlockUserTitle => 'Block user?';

  @override
  String chatBlockUserBody(Object name) {
    return 'Block $name? You will no longer interact in chat.';
  }

  @override
  String get chatBlockUserConfirm => 'Block';

  @override
  String get chatBlockUserSuccess => 'User blocked.';

  @override
  String get eventsPlaceholderTitle => 'Events';

  @override
  String get mapPlaceholderTitle => 'Map';

  @override
  String get chatsPlaceholderTitle => 'Chats';

  @override
  String get profilePlaceholderTitle => 'Profile';
}
