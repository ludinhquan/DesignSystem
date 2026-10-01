// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get languageName => 'Tiếng Việt';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String homeWelcome(String appName) {
    return 'Chào mừng bạn đến với $appName!';
  }

  @override
  String get homeLanguage => 'Ngôn ngữ';

  @override
  String get dsLoading => 'Đang tải';

  @override
  String get dsErrorTitle => 'Đã có lỗi xảy ra';

  @override
  String get dsRetry => 'Thử lại';
}
