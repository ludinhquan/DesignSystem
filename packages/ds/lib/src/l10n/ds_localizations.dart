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
