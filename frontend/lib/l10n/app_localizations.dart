import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'FelloWay'**
  String get appTitle;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonErrorTitle;

  /// Snack bar when an action fails due to no network or unreachable server
  ///
  /// In en, this message translates to:
  /// **'Action unavailable. No internet connection.'**
  String get connectivityActionUnavailable;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @guestSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get guestSignInPrompt;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use LinkedIn to continue.'**
  String get signInSubtitle;

  /// No description provided for @oauthLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with LinkedIn'**
  String get oauthLinkedIn;

  /// No description provided for @oauthFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get oauthFacebook;

  /// No description provided for @oauthNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'OAuth is not configured. Set OAUTH_CLIENT_ID dart-define (LinkedIn). Discovery URL is not required on web.'**
  String get oauthNotConfigured;

  /// No description provided for @oauthMissingTokens.
  ///
  /// In en, this message translates to:
  /// **'No access token returned.'**
  String get oauthMissingTokens;

  /// No description provided for @oauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {message}'**
  String oauthFailed(Object message);

  /// No description provided for @oauthSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get oauthSessionExpired;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'FelloWay helps you network before IT conferences and coordinate rides.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingWelcomeGetStarted;

  /// No description provided for @onboardingWelcomeLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get onboardingWelcomeLogIn;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests and hobbies'**
  String get onboardingInterestsTitle;

  /// No description provided for @onboardingInterestsSection.
  ///
  /// In en, this message translates to:
  /// **'Professional interests'**
  String get onboardingInterestsSection;

  /// No description provided for @onboardingHobbiesSection.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get onboardingHobbiesSection;

  /// No description provided for @onboardingHobbiesLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you enjoy?'**
  String get onboardingHobbiesLabel;

  /// No description provided for @onboardingCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Home city'**
  String get onboardingCityTitle;

  /// No description provided for @onboardingCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get onboardingCityLabel;

  /// No description provided for @onboardingGoToEvents.
  ///
  /// In en, this message translates to:
  /// **'Go to events'**
  String get onboardingGoToEvents;

  /// No description provided for @onboardingSignInToFinish.
  ///
  /// In en, this message translates to:
  /// **'Sign in to finish'**
  String get onboardingSignInToFinish;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile: {message}'**
  String onboardingSaveFailed(Object message);

  /// No description provided for @eventsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsScreenTitle;

  /// No description provided for @eventsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, tag, or city'**
  String get eventsSearchHint;

  /// No description provided for @eventCardGuestHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see who else is going.'**
  String get eventCardGuestHint;

  /// No description provided for @eventCardOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to open event details'**
  String get eventCardOpenHint;

  /// No description provided for @eventCardAttendeeTeaser.
  ///
  /// In en, this message translates to:
  /// **'People also attending:'**
  String get eventCardAttendeeTeaser;

  /// No description provided for @eventJoin.
  ///
  /// In en, this message translates to:
  /// **'I\'m going'**
  String get eventJoin;

  /// No description provided for @eventLeave.
  ///
  /// In en, this message translates to:
  /// **'Cancel attendance'**
  String get eventLeave;

  /// No description provided for @eventJoinSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join'**
  String get eventJoinSignIn;

  /// No description provided for @eventParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get eventParticipantsTitle;

  /// No description provided for @eventGuestBlurHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see participants.'**
  String get eventGuestBlurHint;

  /// No description provided for @eventSchedule.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String eventSchedule(Object start, Object end);

  /// No description provided for @eventCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {count}'**
  String eventCapacity(Object count);

  /// No description provided for @eventPrice.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}'**
  String eventPrice(Object price);

  /// No description provided for @eventOfficialLink.
  ///
  /// In en, this message translates to:
  /// **'Official website'**
  String get eventOfficialLink;

  /// No description provided for @mapScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapScreenTitle;

  /// No description provided for @mapDiscoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Browse events by interest. Full map tiles can be enabled with a maps API key.'**
  String get mapDiscoveryHint;

  /// No description provided for @mapFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mapFilterAll;

  /// No description provided for @mapClusterEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String mapClusterEventsCount(Object count);

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @profileGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your profile.'**
  String get profileGuestMessage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating: {value}'**
  String profileRating(Object value);

  /// No description provided for @profileLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get profileLinkedIn;

  /// No description provided for @profileFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get profileFacebook;

  /// No description provided for @profileInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get profileInterests;

  /// No description provided for @profileHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get profileHobbies;

  /// No description provided for @chatsGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your chats.'**
  String get chatsGuestMessage;

  /// No description provided for @chatsStreamKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Chat is not enabled on this deploy. Set the GitHub STREAM_API_KEY variable for this environment and redeploy the web app (CI build-time config only).'**
  String get chatsStreamKeyHint;

  /// No description provided for @chatsConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to chat…'**
  String get chatsConnecting;

  /// No description provided for @chatsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load chats: {message}'**
  String chatsLoadError(Object message);

  /// No description provided for @chatOpenEventChat.
  ///
  /// In en, this message translates to:
  /// **'Event chat'**
  String get chatOpenEventChat;

  /// No description provided for @chatMessageUser.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageUser;

  /// No description provided for @chatChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatChannelTitle;

  /// No description provided for @chatDmReadOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'You left this event — messages are read-only.'**
  String get chatDmReadOnlyHint;

  /// No description provided for @chatReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReportTitle;

  /// No description provided for @chatReportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get chatReportDetailsLabel;

  /// No description provided for @chatReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we will review this report.'**
  String get chatReportSubmitted;

  /// No description provided for @chatReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get chatReportSubmit;

  /// No description provided for @chatBlockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block user?'**
  String get chatBlockUserTitle;

  /// No description provided for @chatBlockUserBody.
  ///
  /// In en, this message translates to:
  /// **'Block {name}? You will no longer interact in chat.'**
  String chatBlockUserBody(Object name);

  /// No description provided for @chatBlockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chatBlockUserConfirm;

  /// No description provided for @chatBlockUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get chatBlockUserSuccess;

  /// No description provided for @eventsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsPlaceholderTitle;

  /// No description provided for @mapPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapPlaceholderTitle;

  /// No description provided for @chatsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsPlaceholderTitle;

  /// No description provided for @profilePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePlaceholderTitle;

  /// No description provided for @tripsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip chats'**
  String get tripsSectionTitle;

  /// No description provided for @tripsJoinEventHint.
  ///
  /// In en, this message translates to:
  /// **'Join this event to see trip chats and coordinate rides.'**
  String get tripsJoinEventHint;

  /// No description provided for @tripsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trip chats yet — create one for your route.'**
  String get tripsEmpty;

  /// No description provided for @tripCreateCta.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get tripCreateCta;

  /// No description provided for @tripCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create trip chat'**
  String get tripCreateTitle;

  /// No description provided for @tripRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get tripRouteLabel;

  /// No description provided for @tripTargetCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Target city'**
  String get tripTargetCityLabel;

  /// No description provided for @tripDepartureLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get tripDepartureLabel;

  /// No description provided for @tripDepartureValue.
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String tripDepartureValue(Object value);

  /// No description provided for @tripRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get tripRoleLabel;

  /// No description provided for @tripRoleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get tripRoleDriver;

  /// No description provided for @tripRolePassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get tripRolePassenger;

  /// No description provided for @tripRoleEither.
  ///
  /// In en, this message translates to:
  /// **'Either'**
  String get tripRoleEither;

  /// No description provided for @tripCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats (max 20): {count}'**
  String tripCapacityLabel(Object count);

  /// No description provided for @tripCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tripCreateSubmit;

  /// No description provided for @tripCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip chat created.'**
  String get tripCreateSuccess;

  /// No description provided for @tripCardMeta.
  ///
  /// In en, this message translates to:
  /// **'{departure} · {city} · {role} · {members}/{capacity}'**
  String tripCardMeta(
    Object departure,
    Object city,
    Object role,
    Object members,
    Object capacity,
  );

  /// No description provided for @tripRequestJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get tripRequestJoin;

  /// No description provided for @tripJoinAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Same city as this chat — you should be approved automatically.'**
  String get tripJoinAutoHint;

  /// No description provided for @tripJoinManualHint.
  ///
  /// In en, this message translates to:
  /// **'Different city — the owner must approve your request.'**
  String get tripJoinManualHint;

  /// No description provided for @tripJoinRequested.
  ///
  /// In en, this message translates to:
  /// **'Join request sent.'**
  String get tripJoinRequested;

  /// No description provided for @tripPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval.'**
  String get tripPendingHint;

  /// No description provided for @tripCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get tripCancelRequest;

  /// No description provided for @tripCancelRequestDone.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get tripCancelRequestDone;

  /// No description provided for @tripOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get tripOpenChat;

  /// No description provided for @tripManageRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tripManageRequests;

  /// No description provided for @tripRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Join requests'**
  String get tripRequestsTitle;

  /// No description provided for @tripApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get tripApprove;

  /// No description provided for @tripApproved.
  ///
  /// In en, this message translates to:
  /// **'Member approved.'**
  String get tripApproved;

  /// No description provided for @tripRequesterCity.
  ///
  /// In en, this message translates to:
  /// **'From: {city}'**
  String tripRequesterCity(Object city);

  /// No description provided for @tripLowRatingWarning.
  ///
  /// In en, this message translates to:
  /// **'Low rating — review carefully before approving.'**
  String get tripLowRatingWarning;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationGlobalTitle.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get notificationGlobalTitle;

  /// No description provided for @notificationGlobalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master switch for push alerts'**
  String get notificationGlobalSubtitle;

  /// No description provided for @notificationEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event updates'**
  String get notificationEventsTitle;

  /// No description provided for @notificationEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders and event chat activity'**
  String get notificationEventsSubtitle;

  /// No description provided for @notificationTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip chats'**
  String get notificationTripsTitle;

  /// No description provided for @notificationTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join requests and trip messages'**
  String get notificationTripsSubtitle;

  /// No description provided for @notificationDmTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct messages'**
  String get notificationDmTitle;

  /// No description provided for @notificationDmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'DMs from other attendees'**
  String get notificationDmSubtitle;

  /// No description provided for @eventFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Event feedback'**
  String get eventFeedbackTitle;

  /// No description provided for @eventFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How was this event for you?'**
  String get eventFeedbackSubtitle;

  /// No description provided for @eventFeedbackCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get eventFeedbackCommentLabel;

  /// No description provided for @eventFeedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get eventFeedbackSubmit;

  /// No description provided for @eventFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback.'**
  String get eventFeedbackThanks;

  /// No description provided for @eventFeedbackStarLabel.
  ///
  /// In en, this message translates to:
  /// **'{rating} out of 5 stars'**
  String eventFeedbackStarLabel(Object rating);

  /// No description provided for @eventLeaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get eventLeaveFeedback;

  /// No description provided for @reviewsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reviews'**
  String get reviewsListTitle;

  /// No description provided for @reviewsAnonymousEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get reviewsAnonymousEvent;

  /// No description provided for @reviewSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Review: {eventTitle}, {rating} stars. {comment}'**
  String reviewSemanticLabel(Object eventTitle, Object rating, Object comment);

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileEditBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileEditBioLabel;

  /// No description provided for @profileEditInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Interests (comma-separated)'**
  String get profileEditInterestsHint;

  /// No description provided for @profileEditChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileEditChangePhoto;

  /// No description provided for @profileEditAvatarDone.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated.'**
  String get profileEditAvatarDone;

  /// No description provided for @profileEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileEditSave;

  /// No description provided for @profileEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileEditSaved;

  /// No description provided for @profileMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileMenuEdit;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews about you'**
  String get profileMenuReviews;

  /// No description provided for @onboardingWelcomeSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FelloWay. Networking before IT conferences and trip coordination. Get started to create your profile, or log in if you already have an account.'**
  String get onboardingWelcomeSemanticsLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
