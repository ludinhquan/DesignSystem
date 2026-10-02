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

  /// This language's own name, shown in the language list.
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

  /// Email field example.
  ///
  /// In en, this message translates to:
  /// **'lan@example.com'**
  String get loginEmailPlaceholder;

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

  /// Validation: empty email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get loginEmailRequired;

  /// Validation: empty password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get loginPasswordRequired;

  /// Shown on the login screen when no backend is configured.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: any email works. The password \"wrong\" shows an error.'**
  String get loginDemoHint;

  /// Tab bar.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Tab bar.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get tabCards;

  /// Tab bar.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// Tab bar.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// Home greeting before noon.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Home greeting 12–18h.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Home greeting after 18h.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Eyebrow above the total.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get homeTotalBalance;

  /// Eye button when the balance is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get homeShowBalance;

  /// Eye button when the balance is shown.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get homeHideBalance;

  /// Delta chip.
  ///
  /// In en, this message translates to:
  /// **'{amount} this month'**
  String homeDelta(String amount);

  /// Search button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Bell button and sheet title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Empty notifications.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get notificationsEmptyTitle;

  /// Empty notifications.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tell you when something happens.'**
  String get notificationsEmptyMessage;

  /// Quick action and sheet title.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get actionTransfer;

  /// Quick action and sheet title.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get actionTopUp;

  /// Quick action.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get actionScan;

  /// Quick action.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get actionBills;

  /// Sheet for an unfinished feature.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// Sheet for an unfinished feature.
  ///
  /// In en, this message translates to:
  /// **'{feature} isn\'t ready yet.'**
  String comingSoonMessage(String feature);

  /// Section and screen title.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// Section link.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Activity filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Activity filter.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get filterSpent;

  /// Activity filter.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get filterReceived;

  /// Empty activity.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get activityEmptyTitle;

  /// Empty activity.
  ///
  /// In en, this message translates to:
  /// **'Your first transaction will show up here.'**
  String get activityEmptyMessage;

  /// Row time for yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} · {time}'**
  String rowSubtitle(String category, String time);

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get catCoffee;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get catIncome;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get catGift;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get catTransfer;

  /// Category name.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get catTopUp;

  /// Cards screen title.
  ///
  /// In en, this message translates to:
  /// **'My cards'**
  String get cardsTitle;

  /// Pay screen title.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payTitle;

  /// Tap to pay, ready.
  ///
  /// In en, this message translates to:
  /// **'Hold the back of your phone near the reader'**
  String get payReady;

  /// Tap to pay, done.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paySuccess;

  /// Demo payment button.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payTry(String amount);

  /// After a payment.
  ///
  /// In en, this message translates to:
  /// **'Back to cards'**
  String get payBack;

  /// Profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Settings group header.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// Language row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Hide balances toggle.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get settingsHideBalance;

  /// Footer under settings.
  ///
  /// In en, this message translates to:
  /// **'Balances show as dots until you reveal them.'**
  String get settingsHideBalanceFooter;

  /// Logout button.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Transfer field label.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get transferRecipient;

  /// Transfer field example.
  ///
  /// In en, this message translates to:
  /// **'Hoa Chu'**
  String get transferRecipientPlaceholder;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter who receives the money.'**
  String get transferRecipientRequired;

  /// AmountField label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Transfer confirm.
  ///
  /// In en, this message translates to:
  /// **'Send {amount}'**
  String transferSend(String amount);

  /// Transfer in progress.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get transferSending;

  /// Top-up confirm.
  ///
  /// In en, this message translates to:
  /// **'Top up {amount}'**
  String topUpConfirm(String amount);

  /// The linked bank a top-up comes from.
  ///
  /// In en, this message translates to:
  /// **'Techcombank •• 4821'**
  String get topUpSource;

  /// Source account picker.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String fromAccount(String account);

  /// NetworkException.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errorNetwork;

  /// UnauthorizedException outside login.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get errorSessionExpired;

  /// UnauthorizedException on login.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorInvalidCredentials;

  /// ServerException.
  ///
  /// In en, this message translates to:
  /// **'The server is having trouble. Try again in a moment.'**
  String get errorServer;

  /// RequestException.
  ///
  /// In en, this message translates to:
  /// **'This request could not be completed.'**
  String get errorRequest;

  /// RequestException insufficient_funds.
  ///
  /// In en, this message translates to:
  /// **'More than the available balance.'**
  String get errorInsufficientFunds;

  /// UnknownException or any other error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorUnknown;

  /// Design system: close button of a sheet.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dsClose;

  /// Design system: a masked balance read aloud.
  ///
  /// In en, this message translates to:
  /// **'Balance hidden'**
  String get dsHiddenAmount;

  /// Design system: an amount read aloud.
  ///
  /// In en, this message translates to:
  /// **'{amount} dong'**
  String dsAmount(String amount);

  /// Design system: an outflow read aloud.
  ///
  /// In en, this message translates to:
  /// **'minus {amount} dong'**
  String dsAmountNegative(String amount);

  /// Design system: an inflow read aloud.
  ///
  /// In en, this message translates to:
  /// **'plus {amount} dong'**
  String dsAmountPositive(String amount);

  /// Design system: card digits read aloud.
  ///
  /// In en, this message translates to:
  /// **'card ending {last4}'**
  String dsCardEnding(String last4);

  /// Design system: AmountField source.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String dsAmountFrom(String account);

  /// Design system: AmountField available balance.
  ///
  /// In en, this message translates to:
  /// **'Available {amount}'**
  String dsAmountAvailable(String amount);

  /// Design system: AmountField over the balance.
  ///
  /// In en, this message translates to:
  /// **'More than the available balance'**
  String get dsAmountOverBalance;

  /// Design system: spinner label.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get dsLoading;

  /// Design system: error view title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dsErrorTitle;

  /// Design system: retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
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
