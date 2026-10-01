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
  String loginTitle(String appName) {
    return 'Đăng nhập vào $appName';
  }

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mật khẩu';

  @override
  String get loginSubmit => 'Đăng nhập';

  @override
  String get loginEmailRequired => 'Vui lòng nhập email';

  @override
  String get loginPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get loginDemoHint =>
      'Chế độ demo: email nào cũng được. Mật khẩu \"wrong\" sẽ báo lỗi.';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String homeWelcome(String appName, String name) {
    return 'Chào mừng bạn đến với $appName, $name!';
  }

  @override
  String homeTapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bạn đã nhấn nút $count lần',
      zero: 'Bạn chưa nhấn nút lần nào',
    );
    return '$_temp0';
  }

  @override
  String get homeTap => 'Nhấn';

  @override
  String get homeLanguage => 'Ngôn ngữ';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get errorNetwork =>
      'Không có kết nối. Vui lòng kiểm tra mạng và thử lại.';

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get errorServer => 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';

  @override
  String get errorRequest => 'Không thể thực hiện yêu cầu.';

  @override
  String get errorUnknown => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get dsLoading => 'Đang tải';

  @override
  String get dsErrorTitle => 'Đã có lỗi xảy ra';

  @override
  String get dsRetry => 'Thử lại';
}
