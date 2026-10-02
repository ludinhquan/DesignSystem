import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_type.dart';
import '../l10n/ds_localizations.dart';
import '../theme/ds_tokens.dart';

/// Amount sizes, mapped to the display type roles.
enum DsMoneySize { hero, entry, card, row }

/// Formatting rules for đồng: vi-VN grouping, no decimals, a true minus.
abstract final class DsMoneyFormat {
  static final _digits = NumberFormat.decimalPattern('vi_VN');

  /// "24.580.000" (no sign, no currency).
  static String digits(int dong) => _digits.format(dong.abs());

  /// "−65.000 ₫" / "+18.500.000 ₫" / "24.580.000 ₫" with a no-break space,
  /// for plain strings (share text, button labels).
  static String format(int dong, {bool sign = false}) =>
      '${prefix(dong, sign: sign)}${digits(dong)} ₫';

  /// U+2212 for outflows; `+` for inflows only when [sign].
  static String prefix(int dong, {bool sign = false}) =>
      dong < 0 ? '−' : (sign && dong > 0 ? '+' : '');

  /// Chip abbreviation: 100000 → "+100K", 1000000 → "+1M".
  static String chip(int dong) {
    final v = dong.abs();
    final s = v >= 1000000 && v % 1000000 == 0
        ? '${v ~/ 1000000}M'
        : v >= 1000 && v % 1000 == 0
        ? '${v ~/ 1000}K'
        : digits(v);
    return '${dong < 0 ? '−' : '+'}$s';
  }
}

/// Every amount in the app: the display face with tabular figures, vi-VN
/// grouping, a true minus and the currency rule (at 24px and up the `₫` is
/// half size, weight 500, `text-2`, raised; below, 0.72em on the baseline).
///
/// Outflows stay `text-1`; inflows shown with [sign] take `positive`. Never
/// red for spending. Screen readers hear "âm 65.000 đồng".
class DsMoney extends StatelessWidget {
  const DsMoney(
    this.value, {
    this.size = DsMoneySize.row,
    this.sign = false,
    this.hidden = false,
    this.roll = false,
    this.onObject,
    this.style,
    this.textAlign,
    super.key,
  });

  /// In đồng (an integer).
  final int value;
  final DsMoneySize size;

  /// Show `+` on inflows (activity rows); inflows then turn `positive`.
  final bool sign;

  /// Masked as `••••••` with the same footprint.
  final bool hidden;

  /// Digits that change roll on the roll spring, staggered right to left.
  final bool roll;

  /// On an object face: ink and currency take the field's inks.
  final DsFieldColors? onObject;

  /// Overrides the size's type role (keeps the currency rule).
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final base =
        style ??
        switch (size) {
          DsMoneySize.hero => ds.text.displayHero,
          DsMoneySize.entry => ds.text.displayEntry,
          DsMoneySize.card => ds.text.displayCard,
          DsMoneySize.row => ds.text.amountRow,
        };
    final inflow = sign && value > 0;
    final ink =
        onObject?.ink ?? (inflow ? ds.colors.positive : ds.colors.text1);
    final currencyInk =
        onObject?.ink2 ?? (inflow ? ds.colors.positive : ds.colors.text2);
    final textStyle = base.copyWith(color: ink);
    final number =
        '${DsMoneyFormat.prefix(value, sign: sign)}${DsMoneyFormat.digits(value)}';
    final l10n = DsLocalizations.of(context);
    final spoken = hidden
        ? l10n.hiddenAmount
        : l10n.amountSemantics(
            DsMoneyFormat.digits(value),
            negative: value < 0,
            positive: inflow,
          );

    final body = Text.rich(
      TextSpan(
        // The line takes the amount's metrics, so the raised ₫ aligns to
        // its cap height.
        style: textStyle,
        children: [
          if (roll)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: _RollingDigits(number, style: textStyle),
            )
          else
            TextSpan(text: number),
          _currency(textStyle, currencyInk),
        ],
      ),
      textAlign: textAlign,
      maxLines: 1,
      softWrap: false,
    );

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: hidden ? _Masked(style: textStyle, child: body) : body,
    );
  }

  InlineSpan _currency(TextStyle style, Color color) {
    final fontSize = style.fontSize ?? 17;
    if (fontSize >= 24) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.top,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: fontSize * 0.16,
            top: fontSize * 0.12,
          ),
          child: Text(
            '₫',
            style: DsTypography.withWeight(
              style.copyWith(fontSize: fontSize * 0.5, height: 1, color: color),
              500,
            ),
          ),
        ),
      );
    }
    return TextSpan(
      text: ' ₫',
      style: style.copyWith(fontSize: fontSize * 0.72, color: color),
    );
  }
}

/// Keeps the real amount's footprint and shows dots over it.
class _Masked extends StatelessWidget {
  const _Masked({required this.style, required this.child});

  final TextStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: AlignmentDirectional.centerStart,
    children: [
      Visibility.maintain(visible: false, child: child),
      Text('••••••', style: style, maxLines: 1, softWrap: false),
    ],
  );
}

/// One fixed-width slot per character. Changed characters slide in from
/// below on the roll spring, 24ms apart from the right. Reduce Motion
/// cross-fades instead.
class _RollingDigits extends StatelessWidget {
  const _RollingDigits(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final m = context.ds.motion;
    final reduce = context.dsReduceMotion;
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        for (var i = 0; i < chars.length; i++)
          () {
            final fromRight = chars.length - 1 - i;
            final delay = m.rollStagger * fromRight;
            final total = m.roll.duration + delay;
            final start = delay.inMicroseconds / total.inMicroseconds;
            return ClipRect(
              child: AnimatedSwitcher(
                // Keyed by position from the right, so the ones digit stays
                // the ones digit when the length changes.
                key: ValueKey(fromRight),
                duration: reduce ? m.fadeLong : total,
                switchInCurve: reduce
                    ? Curves.linear
                    : Interval(start, 1, curve: m.roll.curve),
                switchOutCurve: Curves.linear,
                transitionBuilder: (child, animation) => reduce
                    ? FadeTransition(opacity: animation, child: child)
                    : SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.9),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.bottomCenter,
                  children: [...previous, ?current],
                ),
                child: Text(chars[i], key: ValueKey(chars[i]), style: style),
              ),
            );
          }(),
      ],
    );
  }
}
