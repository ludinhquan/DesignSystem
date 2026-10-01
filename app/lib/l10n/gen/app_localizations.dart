import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('vi'),
  ];

  /// This language's own name, shown in the language switch.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// Login screen heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {appName}'**
  String loginTitle(String appName);

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// Login button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// Validation error for an empty email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailRequired;

  /// Validation error for an empty password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// Shown on the login screen when no backend is configured.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: any email works. The password \"wrong\" shows an error.'**
  String get loginDemoHint;

  /// Home screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Greeting on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}, {name}!'**
  String homeWelcome(String appName, String name);

  /// Per-user counter, reset on logout.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You have not tapped the button yet} =1{You tapped the button once} other{You tapped the button {count} times}}'**
  String homeTapCount(int count);

  /// Button that increments the counter.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get homeTap;

  /// Label of the language switch.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeLanguage;

  /// Logout action.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// NetworkException.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errorNetwork;

  /// UnauthorizedException outside the login screen.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// UnauthorizedException on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorInvalidCredentials;

  /// ServerException (5xx).
  ///
  /// In en, this message translates to:
  /// **'The server is having trouble. Please try again later.'**
  String get errorServer;

  /// RequestException (other 4xx).
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed.'**
  String get errorRequest;

  /// UnknownException or any other error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// Design system: spinner label for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get dsLoading;

  /// Design system: default error view title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dsErrorTitle;

  /// Design system: default retry button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dsRetry;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
