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
  String get homeTitle => 'Home';

  @override
  String homeWelcome(String appName) {
    return 'Welcome to $appName!';
  }

  @override
  String get homeLanguage => 'Language';

  @override
  String get dsLoading => 'Loading';

  @override
  String get dsErrorTitle => 'Something went wrong';

  @override
  String get dsRetry => 'Retry';
}
