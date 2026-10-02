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
  String get loginEmailPlaceholder => 'lan@example.com';

  @override
  String get loginPassword => 'Mật khẩu';

  @override
  String get loginSubmit => 'Đăng nhập';

  @override
  String get loginEmailRequired => 'Nhập email của bạn.';

  @override
  String get loginPasswordRequired => 'Nhập mật khẩu của bạn.';

  @override
  String get loginDemoHint =>
      'Chế độ demo: email nào cũng được. Mật khẩu \"wrong\" sẽ báo lỗi.';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabCards => 'Thẻ';

  @override
  String get tabActivity => 'Hoạt động';

  @override
  String get tabProfile => 'Cá nhân';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get homeTotalBalance => 'Tổng số dư';

  @override
  String get homeShowBalance => 'Hiện số dư';

  @override
  String get homeHideBalance => 'Ẩn số dư';

  @override
  String homeDelta(String amount) {
    return '$amount tháng này';
  }

  @override
  String get search => 'Tìm kiếm';

  @override
  String get notifications => 'Thông báo';

  @override
  String get notificationsEmptyTitle => 'Không có thông báo mới';

  @override
  String get notificationsEmptyMessage =>
      'Bạn sẽ nhận thông báo khi có thay đổi.';

  @override
  String get actionTransfer => 'Chuyển tiền';

  @override
  String get actionTopUp => 'Nạp tiền';

  @override
  String get actionScan => 'Quét QR';

  @override
  String get actionBills => 'Hoá đơn';

  @override
  String get comingSoonTitle => 'Sắp ra mắt';

  @override
  String comingSoonMessage(String feature) {
    return '$feature đang được hoàn thiện.';
  }

  @override
  String get activityTitle => 'Hoạt động';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterSpent => 'Chi';

  @override
  String get filterReceived => 'Thu';

  @override
  String get activityEmptyTitle => 'Chưa có giao dịch';

  @override
  String get activityEmptyMessage => 'Giao dịch đầu tiên sẽ hiện ở đây.';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String rowSubtitle(String category, String time) {
    return '$category · $time';
  }

  @override
  String get catCoffee => 'Cà phê';

  @override
  String get catFood => 'Ăn uống';

  @override
  String get catTransport => 'Di chuyển';

  @override
  String get catShopping => 'Mua sắm';

  @override
  String get catBills => 'Hoá đơn';

  @override
  String get catUtilities => 'Điện nước';

  @override
  String get catHealth => 'Sức khoẻ';

  @override
  String get catIncome => 'Thu nhập';

  @override
  String get catGift => 'Quà tặng';

  @override
  String get catTransfer => 'Chuyển tiền';

  @override
  String get catTopUp => 'Nạp tiền';

  @override
  String get cardsTitle => 'Thẻ của tôi';

  @override
  String get payTitle => 'Thanh toán';

  @override
  String get payReady => 'Giữ mặt sau điện thoại gần máy POS';

  @override
  String get paySuccess => 'Đã thanh toán';

  @override
  String payTry(String amount) {
    return 'Thanh toán $amount';
  }

  @override
  String get payBack => 'Về danh sách thẻ';

  @override
  String get profileTitle => 'Cá nhân';

  @override
  String get profileSettings => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsHideBalance => 'Ẩn số dư';

  @override
  String get settingsHideBalanceFooter =>
      'Số dư hiện dạng chấm cho đến khi bạn bấm hiện.';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get transferRecipient => 'Người nhận';

  @override
  String get transferRecipientPlaceholder => 'Hoà Chu';

  @override
  String get transferRecipientRequired => 'Nhập tên người nhận.';

  @override
  String get amountLabel => 'Số tiền';

  @override
  String transferSend(String amount) {
    return 'Gửi $amount';
  }

  @override
  String get transferSending => 'Đang gửi…';

  @override
  String topUpConfirm(String amount) {
    return 'Nạp $amount';
  }

  @override
  String get topUpSource => 'Techcombank •• 4821';

  @override
  String fromAccount(String account) {
    return 'Từ $account';
  }

  @override
  String get errorNetwork => 'Không có kết nối. Kiểm tra mạng rồi thử lại.';

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get errorServer => 'Máy chủ đang gặp sự cố. Hãy thử lại sau ít phút.';

  @override
  String get errorRequest => 'Không thể thực hiện yêu cầu này.';

  @override
  String get errorInsufficientFunds => 'Vượt quá số dư khả dụng.';

  @override
  String get errorUnknown => 'Đã có lỗi xảy ra. Hãy thử lại.';

  @override
  String get dsClose => 'Đóng';

  @override
  String get dsHiddenAmount => 'Số dư đã ẩn';

  @override
  String dsAmount(String amount) {
    return '$amount đồng';
  }

  @override
  String dsAmountNegative(String amount) {
    return 'âm $amount đồng';
  }

  @override
  String dsAmountPositive(String amount) {
    return 'cộng $amount đồng';
  }

  @override
  String dsCardEnding(String last4) {
    return 'thẻ đuôi $last4';
  }

  @override
  String dsAmountFrom(String account) {
    return 'Từ $account';
  }

  @override
  String dsAmountAvailable(String amount) {
    return 'Khả dụng $amount';
  }

  @override
  String get dsAmountOverBalance => 'Vượt quá số dư khả dụng';

  @override
  String get dsLoading => 'Đang tải';

  @override
  String get dsErrorTitle => 'Đã có lỗi xảy ra';

  @override
  String get dsRetry => 'Thử lại';
}
