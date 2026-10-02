/// The colour the person picked for an account. It is that account's colour
/// everywhere (card, row dot, pickers). The UI maps it to a design-system
/// field; data never imports the design system.
enum AccountColor {
  yellow,
  red,
  blue,
  green,
  purple,
  graphite;

  static AccountColor parse(Object? v) =>
      values.firstWhere((c) => c.name == v, orElse: () => yellow);
}

/// Spending and income categories. Each has one emoji and one glyph in the
/// UI.
enum Category {
  coffee,
  food,
  transport,
  shopping,
  bills,
  utilities,
  health,
  income,
  gift,
  transfer,
  topUp;

  static Category parse(Object? v) =>
      values.firstWhere((c) => c.name == v, orElse: () => transfer);
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.institution,
    required this.last4,
    required this.color,
    required this.balance,
  });

  factory Account.fromJson(Map<String, Object?> json) => switch (json) {
    {
      'id': final String id,
      'name': final String name,
      'institution': final String institution,
      'last4': final String last4,
      'balance': final int balance,
    } =>
      Account(
        id: id,
        name: name,
        institution: institution,
        last4: last4,
        color: AccountColor.parse(json['color']),
        balance: balance,
      ),
    _ => throw FormatException('Bad account: $json'),
  };

  final String id;

  /// The person's own name for it ("Chi tiêu hằng ngày").
  final String name;

  /// The bank, as plain text.
  final String institution;
  final String last4;
  final AccountColor color;

  /// In đồng.
  final int balance;

  Account withBalance(int b) => Account(
    id: id,
    name: name,
    institution: institution,
    last4: last4,
    color: color,
    balance: b,
  );
}

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.accountId,
    required this.amount,
    required this.at,
    this.person = false,
  });

  factory Transaction.fromJson(Map<String, Object?> json) => switch (json) {
    {
      'id': final String id,
      'title': final String title,
      'account_id': final String accountId,
      'amount': final int amount,
      'at': final String at,
    } =>
      Transaction(
        id: id,
        title: title,
        category: Category.parse(json['category']),
        accountId: accountId,
        amount: amount,
        at: DateTime.parse(at),
        person: json['person'] == true,
      ),
    _ => throw FormatException('Bad transaction: $json'),
  };

  final String id;

  /// Merchant or person.
  final String title;
  final Category category;
  final String accountId;

  /// Signed, in đồng: outflows are negative.
  final int amount;
  final DateTime at;

  /// The counterparty is a person (shown with initials, not a category).
  final bool person;
}

/// Everything a signed-in person sees on the money screens.
class Wallet {
  const Wallet({required this.accounts, required this.transactions});

  static const empty = Wallet(accounts: [], transactions: []);

  final List<Account> accounts;

  /// Newest first.
  final List<Transaction> transactions;

  int get total => accounts.fold(0, (sum, a) => sum + a.balance);

  Account? account(String id) {
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Net change since the start of [now]'s month.
  int monthDelta(DateTime now) => transactions
      .where((t) => t.at.year == now.year && t.at.month == now.month)
      .fold(0, (sum, t) => sum + t.amount);
}
