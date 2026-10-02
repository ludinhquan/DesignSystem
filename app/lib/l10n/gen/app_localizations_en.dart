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
  String get loginEmailPlaceholder => 'lan@example.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginEmailRequired => 'Enter your email.';

  @override
  String get loginPasswordRequired => 'Enter your password.';

  @override
  String get loginDemoHint =>
      'Demo mode: any email works. The password \"wrong\" shows an error.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCards => 'Cards';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabProfile => 'Profile';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get homeTotalBalance => 'Total balance';

  @override
  String get homeShowBalance => 'Show balance';

  @override
  String get homeHideBalance => 'Hide balance';

  @override
  String homeDelta(String amount) {
    return '$amount this month';
  }

  @override
  String get search => 'Search';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'All caught up';

  @override
  String get notificationsEmptyMessage =>
      'We\'ll tell you when something happens.';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionTopUp => 'Top up';

  @override
  String get actionScan => 'Scan QR';

  @override
  String get actionBills => 'Bills';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String comingSoonMessage(String feature) {
    return '$feature isn\'t ready yet.';
  }

  @override
  String get activityTitle => 'Activity';

  @override
  String get seeAll => 'See all';

  @override
  String get filterAll => 'All';

  @override
  String get filterSpent => 'Spent';

  @override
  String get filterReceived => 'Received';

  @override
  String get activityEmptyTitle => 'No transactions yet';

  @override
  String get activityEmptyMessage =>
      'Your first transaction will show up here.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String rowSubtitle(String category, String time) {
    return '$category · $time';
  }

  @override
  String get catCoffee => 'Coffee';

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catBills => 'Bills';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catHealth => 'Health';

  @override
  String get catIncome => 'Income';

  @override
  String get catGift => 'Gifts';

  @override
  String get catTransfer => 'Transfer';

  @override
  String get catTopUp => 'Top-up';

  @override
  String get cardsTitle => 'My cards';

  @override
  String get payTitle => 'Pay';

  @override
  String get payReady => 'Hold the back of your phone near the reader';

  @override
  String get paySuccess => 'Paid';

  @override
  String payTry(String amount) {
    return 'Pay $amount';
  }

  @override
  String get payBack => 'Back to cards';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsHideBalance => 'Hide balances';

  @override
  String get settingsHideBalanceFooter =>
      'Balances show as dots until you reveal them.';

  @override
  String get logout => 'Log out';

  @override
  String get transferRecipient => 'Recipient';

  @override
  String get transferRecipientPlaceholder => 'Hoa Chu';

  @override
  String get transferRecipientRequired => 'Enter who receives the money.';

  @override
  String get amountLabel => 'Amount';

  @override
  String transferSend(String amount) {
    return 'Send $amount';
  }

  @override
  String get transferSending => 'Sending…';

  @override
  String topUpConfirm(String amount) {
    return 'Top up $amount';
  }

  @override
  String get topUpSource => 'Techcombank •• 4821';

  @override
  String fromAccount(String account) {
    return 'From $account';
  }

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorSessionExpired => 'Your session has expired. Sign in again.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorServer =>
      'The server is having trouble. Try again in a moment.';

  @override
  String get errorRequest => 'This request could not be completed.';

  @override
  String get errorInsufficientFunds => 'More than the available balance.';

  @override
  String get errorUnknown => 'Something went wrong. Try again.';

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
  String get dsRetry => 'Try again';
}
