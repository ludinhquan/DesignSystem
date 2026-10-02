import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The strings that design-system components show or announce.
///
/// The package ships no translations. The app provides a
/// `LocalizationsDelegate<DsLocalizations>` that maps these to its own ARB
/// strings, so every language the app supports covers the components too.
/// Previews, goldens and package tests use [englishDelegate].
abstract class DsLocalizations {
  const DsLocalizations();

  /// Spinner label for screen readers.
  String get loading;

  /// Default `DsErrorView` title.
  String get errorTitle;

  /// Default retry button label.
  String get retry;

  /// Close button of a sheet.
  String get close;

  /// Announced for a masked balance.
  String get hiddenAmount;

  /// How an amount reads aloud. [amount] is already grouped ("65.000");
  /// [negative] / [positive] say whether a sign is shown.
  String amountSemantics(
    String amount, {
    required bool negative,
    required bool positive,
  });

  /// An account card: institution, name, balance (spoken) and last digits.
  String cardSemantics({
    required String name,
    required String balance,
    String? institution,
    String? last4,
  });

  /// AmountField source line ("Từ Chi tiêu hằng ngày").
  String amountFrom(String account);

  /// AmountField available line; [amount] is formatted ("12.450.000 ₫").
  String amountAvailable(String amount);

  /// AmountField error when the amount exceeds the available balance.
  String get amountOverBalance;

  /// Debug builds assert that a delegate is installed, so a missing
  /// translation fails tests instead of showing English. Release builds fall
  /// back to English.
  static DsLocalizations of(BuildContext context) {
    final l10n = Localizations.of<DsLocalizations>(context, DsLocalizations);
    assert(
      l10n != null,
      'No DsLocalizations found. Add a LocalizationsDelegate<DsLocalizations> '
      'to MaterialApp.localizationsDelegates (in tests and previews: '
      'DsLocalizations.englishDelegate).',
    );
    return l10n ?? const _DsLocalizationsEn();
  }

  /// English strings, for previews, goldens and package tests.
  static const LocalizationsDelegate<DsLocalizations> englishDelegate =
      _EnglishDelegate();
}

class _DsLocalizationsEn extends DsLocalizations {
  const _DsLocalizationsEn();

  @override
  String get loading => 'Loading';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get hiddenAmount => 'Balance hidden';

  @override
  String amountSemantics(
    String amount, {
    required bool negative,
    required bool positive,
  }) => '${negative ? 'minus ' : (positive ? 'plus ' : '')}$amount dong';

  @override
  String cardSemantics({
    required String name,
    required String balance,
    String? institution,
    String? last4,
  }) => [
    ?institution,
    name,
    balance,
    if (last4 != null) 'card ending $last4',
  ].join(', ');

  @override
  String amountFrom(String account) => 'From $account';

  @override
  String amountAvailable(String amount) => 'Available $amount';

  @override
  String get amountOverBalance => 'More than the available balance';
}

class _EnglishDelegate extends LocalizationsDelegate<DsLocalizations> {
  const _EnglishDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<DsLocalizations> load(Locale locale) =>
      SynchronousFuture(const _DsLocalizationsEn());

  @override
  bool shouldReload(_EnglishDelegate old) => false;
}
