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
  /// **'Use LinkedIn or Facebook to continue.'**
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

  /// No description provided for @demoSignIn.
  ///
  /// In en, this message translates to:
  /// **'Demo sign-in (debug)'**
  String get demoSignIn;

  /// No description provided for @oauthNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'OAuth is not configured. Set OAUTH_* dart-define values.'**
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
  /// **'Set STREAM_API_KEY to enable GetStream chat.'**
  String get chatsStreamKeyHint;

  /// No description provided for @chatsConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to chat…'**
  String get chatsConnecting;

  /// No description provided for @chatsDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo API: chat uses GetStream only with a real backend token.'**
  String get chatsDemoHint;

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
