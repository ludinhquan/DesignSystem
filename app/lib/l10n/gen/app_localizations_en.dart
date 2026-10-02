// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String loginTitle(String appName) {
    return 'Sign in to $appName';
  }

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginDemoHint =>
      'Demo mode: any email works. The password \"wrong\" shows an error.';

  @override
  String get homeTitle => 'Home';

  @override
  String homeWelcome(String appName, String name) {
    return 'Welcome to $appName, $name!';
  }

  @override
  String homeTapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You tapped the button $count times',
      one: 'You tapped the button once',
      zero: 'You have not tapped the button yet',
    );
    return '$_temp0';
  }

  @override
  String get homeTap => 'Tap';

  @override
  String get homeLanguage => 'Language';

  @override
  String get logout => 'Log out';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorServer =>
      'The server is having trouble. Please try again later.';

  @override
  String get errorRequest => 'The request could not be completed.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get dsClose => 'Close';

  @override
  String get dsHiddenAmount => 'Balance hidden';

  @override
  String dsAmount(String amount) {
    return '$amount dong';
  }

  @override
  String dsAmountNegative(String amount) {
    return 'minus $amount dong';
  }

  @override
  String dsAmountPositive(String amount) {
    return 'plus $amount dong';
  }

  @override
  String dsCardEnding(String last4) {
    return 'card ending $last4';
  }

  @override
  String dsAmountFrom(String account) {
    return 'From $account';
  }

  @override
  String dsAmountAvailable(String amount) {
    return 'Available $amount';
  }

  @override
  String get dsAmountOverBalance => 'More than the available balance';

  @override
  String get dsLoading => 'Loading';

  @override
  String get dsErrorTitle => 'Something went wrong';

  @override
  String get dsRetry => 'Retry';
}
