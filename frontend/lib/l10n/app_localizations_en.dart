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
  String get connectivityActionUnavailable =>
      'Action unavailable. No internet connection.';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get guestSignInPrompt => 'Sign in to continue';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Use LinkedIn to continue.';

  @override
  String get oauthLinkedIn => 'Continue with LinkedIn';

  @override
  String get oauthFacebook => 'Continue with Facebook';

  @override
  String get oauthNotConfigured =>
      'OAuth is not configured. Set OAUTH_CLIENT_ID dart-define (LinkedIn). Discovery URL is not required on web.';

  @override
  String get oauthMissingTokens => 'No access token returned.';

  @override
  String oauthFailed(Object message) {
    return 'Sign-in failed: $message';
  }

  @override
  String get oauthSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeBody =>
      'FelloWay helps you network before IT conferences and coordinate rides.';

  @override
  String get onboardingWelcomeGetStarted => 'Get started';

  @override
  String get onboardingWelcomeLogIn => 'Log in';

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
  String get onboardingSignInToFinish => 'Sign in to finish';

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
  String get eventCardOpenHint => 'Double tap to open event details';

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
  String mapClusterEventsCount(Object count) {
    return '$count events';
  }

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
      'Chat is not enabled on this deploy. Set the GitHub STREAM_API_KEY variable for this environment and redeploy the web app (CI build-time config only).';

  @override
  String get chatsConnecting => 'Connecting to chat…';

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

  @override
  String get tripsSectionTitle => 'Trip chats';

  @override
  String get tripsJoinEventHint =>
      'Join this event to see trip chats and coordinate rides.';

  @override
  String get tripsEmpty => 'No trip chats yet — create one for your route.';

  @override
  String get tripCreateCta => 'New trip';

  @override
  String get tripCreateTitle => 'Create trip chat';

  @override
  String get tripRouteLabel => 'Route';

  @override
  String get tripTargetCityLabel => 'Target city';

  @override
  String get tripDepartureLabel => 'Departure';

  @override
  String tripDepartureValue(Object value) {
    return '$value';
  }

  @override
  String get tripRoleLabel => 'Your role';

  @override
  String get tripRoleDriver => 'Driver';

  @override
  String get tripRolePassenger => 'Passenger';

  @override
  String get tripRoleEither => 'Either';

  @override
  String tripCapacityLabel(Object count) {
    return 'Seats (max 20): $count';
  }

  @override
  String get tripCreateSubmit => 'Create';

  @override
  String get tripCreateSuccess => 'Trip chat created.';

  @override
  String tripCardMeta(
    Object departure,
    Object city,
    Object role,
    Object members,
    Object capacity,
  ) {
    return '$departure · $city · $role · $members/$capacity';
  }

  @override
  String get tripRequestJoin => 'Request to join';

  @override
  String get tripJoinAutoHint =>
      'Same city as this chat — you should be approved automatically.';

  @override
  String get tripJoinManualHint =>
      'Different city — the owner must approve your request.';

  @override
  String get tripJoinRequested => 'Join request sent.';

  @override
  String get tripPendingHint => 'Waiting for approval.';

  @override
  String get tripCancelRequest => 'Cancel request';

  @override
  String get tripCancelRequestDone => 'Request cancelled.';

  @override
  String get tripOpenChat => 'Open chat';

  @override
  String get tripManageRequests => 'Requests';

  @override
  String get tripRequestsTitle => 'Join requests';

  @override
  String get tripApprove => 'Approve';

  @override
  String get tripApproved => 'Member approved.';

  @override
  String tripRequesterCity(Object city) {
    return 'From: $city';
  }

  @override
  String get tripLowRatingWarning =>
      'Low rating — review carefully before approving.';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get notificationGlobalTitle => 'All notifications';

  @override
  String get notificationGlobalSubtitle => 'Master switch for push alerts';

  @override
  String get notificationEventsTitle => 'Event updates';

  @override
  String get notificationEventsSubtitle => 'Reminders and event chat activity';

  @override
  String get notificationTripsTitle => 'Trip chats';

  @override
  String get notificationTripsSubtitle => 'Join requests and trip messages';

  @override
  String get notificationDmTitle => 'Direct messages';

  @override
  String get notificationDmSubtitle => 'DMs from other attendees';

  @override
  String get eventFeedbackTitle => 'Event feedback';

  @override
  String get eventFeedbackSubtitle => 'How was this event for you?';

  @override
  String get eventFeedbackCommentLabel => 'Optional comment';

  @override
  String get eventFeedbackSubmit => 'Submit feedback';

  @override
  String get eventFeedbackThanks => 'Thanks for your feedback.';

  @override
  String eventFeedbackStarLabel(Object rating) {
    return '$rating out of 5 stars';
  }

  @override
  String get eventLeaveFeedback => 'Leave feedback';

  @override
  String get reviewsListTitle => 'Your reviews';

  @override
  String get reviewsAnonymousEvent => 'Event';

  @override
  String reviewSemanticLabel(Object eventTitle, Object rating, Object comment) {
    return 'Review: $eventTitle, $rating stars. $comment';
  }

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditBioLabel => 'Bio';

  @override
  String get profileEditInterestsHint => 'Interests (comma-separated)';

  @override
  String get profileEditChangePhoto => 'Change photo';

  @override
  String get profileEditAvatarDone => 'Avatar updated.';

  @override
  String get profileEditSave => 'Save';

  @override
  String get profileEditSaved => 'Profile saved.';

  @override
  String get profileMenuEdit => 'Edit profile';

  @override
  String get profileMenuNotifications => 'Notification settings';

  @override
  String get profileMenuReviews => 'Reviews about you';

  @override
  String get onboardingWelcomeSemanticsLabel =>
      'Welcome to FelloWay. Networking before IT conferences and trip coordination. Get started to create your profile, or log in if you already have an account.';
}
