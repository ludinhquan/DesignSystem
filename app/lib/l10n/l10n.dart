import 'package:ds/ds.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:material_ui/material_ui.dart';

import '../core/analytics.dart';
import '../core/http.dart';
import '../core/storage.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension L10nContext on BuildContext {
  /// `context.l10n.loginTitle(brand.appName)`
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Every delegate the app needs, for `MaterialApp.localizationsDelegates`.
///
/// Do **not** use the generated `AppLocalizations.localizationsDelegates`: it
/// lists `flutter_localizations`' `GlobalMaterialLocalizations`, which belongs
/// to the in-SDK Material library. material_ui has its own
/// `MaterialLocalizations` type and ships its own
/// `GlobalMaterialLocalizations.delegates` (Material + cupertino_ui + widgets,
/// Vietnamese included), which is what is used here.
const List<LocalizationsDelegate<Object?>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  _DsLocalizationsDelegate(),
  ...GlobalMaterialLocalizations.delegates,
];

/// Feeds the design system's strings from the app's ARB files, so they are
/// translated into every language the app supports.
class _DsLocalizationsDelegate extends LocalizationsDelegate<DsLocalizations> {
  const _DsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<DsLocalizations> load(Locale locale) =>
      SynchronousFuture(_AppDsLocalizations(lookupAppLocalizations(locale)));

  @override
  bool shouldReload(_DsLocalizationsDelegate old) => false;
}

class _AppDsLocalizations extends DsLocalizations {
  const _AppDsLocalizations(this._l10n);

  final AppLocalizations _l10n;

  @override
  String get loading => _l10n.dsLoading;

  @override
  String get errorTitle => _l10n.dsErrorTitle;

  @override
  String get retry => _l10n.dsRetry;

  @override
  String get close => _l10n.dsClose;

  @override
  String get hiddenAmount => _l10n.dsHiddenAmount;

  @override
  String amountSemantics(
    String amount, {
    required bool negative,
    required bool positive,
  }) => negative
      ? _l10n.dsAmountNegative(amount)
      : positive
      ? _l10n.dsAmountPositive(amount)
      : _l10n.dsAmount(amount);

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
    if (last4 != null) _l10n.dsCardEnding(last4),
  ].join(', ');

  @override
  String amountFrom(String account) => _l10n.dsAmountFrom(account);

  @override
  String amountAvailable(String amount) => _l10n.dsAmountAvailable(amount);

  @override
  String get amountOverBalance => _l10n.dsAmountOverBalance;
}

extension ErrorMessages on AppLocalizations {
  /// The user-facing text for any error. Never shows `toString()`.
  String errorMessage(Object error) => switch (error) {
    ProviderException(:final exception) => errorMessage(exception),
    NetworkException() => errorNetwork,
    UnauthorizedException() => errorSessionExpired,
    ServerException() => errorServer,
    RequestException(code: 'insufficient_funds') => errorInsufficientFunds,
    RequestException() => errorRequest,
    UnknownException() => errorUnknown,
    _ => errorUnknown,
  };
}

/// The chosen app language; `null` follows the device. Saved in
/// shared_preferences. Not per-user: it survives logout on purpose.
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  static const _key = 'app.locale';

  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    ref.read(analyticsProvider).track(Events.localeChanged, {
      'locale': locale?.languageCode ?? 'system',
    });
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
