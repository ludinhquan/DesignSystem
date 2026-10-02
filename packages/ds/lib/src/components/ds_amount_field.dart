import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_shadows.dart';
import '../foundation/ds_type.dart';
import '../l10n/ds_localizations.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_ground.dart';
import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';
import 'ds_chip.dart';
import 'ds_money.dart';

/// The money input: a centred display amount with an accent caret,
/// quick-add chips and the source account's available balance.
///
/// Typing over the balance is not blocked: it warns (a shake, an error
/// haptic, a `negative` line with a glyph); the caller disables its confirm.
class DsAmountField extends StatefulWidget {
  const DsAmountField({
    required this.value,
    required this.onChanged,
    required this.available,
    required this.sourceField,
    required this.sourceName,
    this.label,
    this.chips = const [100000, 500000, 1000000],
    this.autofocus = false,
    this.inputKey,
    super.key,
  });

  /// In đồng.
  final int value;
  final ValueChanged<int> onChanged;

  /// The source account's balance.
  final int available;
  final DsField sourceField;
  final String sourceName;

  /// Shown above the amount and used as the field's accessible name.
  final String? label;

  /// Quick-add amounts.
  final List<int> chips;
  final bool autofocus;

  /// Key of the hidden editable text (tests enter digits through it).
  final Key? inputKey;

  static const maxDigits = 12;

  @override
  State<DsAmountField> createState() => _DsAmountFieldState();
}

class _DsAmountFieldState extends State<DsAmountField>
    with TickerProviderStateMixin {
  late final _controller = TextEditingController(text: _text(widget.value));
  final _focus = FocusNode();
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  static String _text(int v) => v == 0 ? '' : '$v';

  bool get _over => widget.value > widget.available;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    final blink = _focus.hasFocus && !context.dsReduceMotion;
    if (blink) {
      _blink.repeat();
    } else {
      _blink.stop();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(DsAmountField old) {
    super.didUpdateWidget(old);
    if (_text(widget.value) != _controller.text) {
      _controller.value = TextEditingValue(
        text: _text(widget.value),
        selection: TextSelection.collapsed(offset: _text(widget.value).length),
      );
    }
    final wasOver = old.value > old.available;
    if (_over && !wasOver) {
      DsHaptics.error(context);
      if (!context.dsReduceMotion) _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _blink.dispose();
    _shake.dispose();
    super.dispose();
  }

  double _sizeFor(int digits) => switch (digits) {
    <= 7 => 60,
    8 => 52,
    <= 10 => 44,
    _ => 36,
  };

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final l10n = DsLocalizations.of(context);
    final digits = widget.value.toString().length;
    final size = _sizeFor(widget.value == 0 ? 1 : digits);
    final entry = ds.text.displayEntry;
    final style = entry.copyWith(
      fontSize: size,
      color: widget.value == 0 ? c.text3 : c.text1,
    );
    final source = c.field(widget.sourceField);

    final amount = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: widget.value == 0
              ? Text('0', style: style, maxLines: 1)
              : DsMoney(widget.value, style: style),
        ),
        if (_focus.hasFocus)
          AnimatedBuilder(
            animation: _blink,
            builder: (context, _) => Opacity(
              opacity: _blink.isAnimating && _blink.value >= 0.5 ? 0 : 1,
              child: Container(
                margin: const EdgeInsetsDirectional.only(start: 4),
                width: 3,
                height: size * 0.86,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
      ],
    );

    return DsBox(
      shape: ds.shape(ds.radius.tile),
      color: DsGround.chrome(context),
      shadow: ds.shadows.surface,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: ds.spacing.s4,
        vertical: ds.spacing.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The hidden input that drives everything; digits only (no
          // decimal key: VND has no decimals).
          SizedBox(
            height: 1,
            child: Opacity(
              opacity: 0,
              child: Semantics(
                label: widget.label,
                child: TextField(
                  key: widget.inputKey,
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(DsAmountField.maxDigits),
                  ],
                  decoration: const InputDecoration.collapsed(hintText: null),
                  onChanged: (t) => widget.onChanged(int.tryParse(t) ?? 0),
                ),
              ),
            ),
          ),
          if (widget.label != null)
            ExcludeSemantics(
              child: Text(
                widget.label!,
                style: ds.text.label.copyWith(color: c.text2),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _focus.requestFocus();
              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
            },
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final t = _shake.value;
                final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: SizedBox(
                height: 64 + ds.spacing.s2,
                width: double.infinity,
                child: Center(child: amount),
              ),
            ),
          ),
          if (_over)
            Semantics(
              liveRegion: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DsGlyph(
                    ds.icons.warning,
                    weight: DsGlyphWeight.fill,
                    size: 16,
                    color: c.negative,
                  ),
                  SizedBox(width: ds.spacing.s1),
                  Flexible(
                    child: Text(
                      l10n.amountOverBalance,
                      style: ds.text.footnote.copyWith(color: c.negative),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: ds.spacing.s3),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: ds.spacing.s2,
            children: [
              for (final chip in widget.chips)
                DsChip(
                  label: DsMoneyFormat.chip(chip),
                  onPressed: () => widget.onChanged(
                    math.min(widget.value + chip, 999999999999),
                  ),
                ),
            ],
          ),
          SizedBox(height: ds.spacing.s4),
          DsBox(
            shape: ds.shape(ds.radius.tileSm),
            color: c.fillSubtle,
            shadow: DsShadow.none,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: ds.spacing.s3,
              vertical: ds.spacing.s2,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28 / ds.size.cardAspect,
                  child: DsObjectFace(
                    field: source,
                    shape: ds.shape(4),
                    grain: false,
                    specular: false,
                  ),
                ),
                SizedBox(width: ds.spacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amountFrom(widget.sourceName),
                        style: DsTypography.withWeight(
                          ds.text.footnote,
                          600,
                        ).copyWith(color: c.text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.amountAvailable(
                          DsMoneyFormat.format(widget.available),
                        ),
                        style: ds.text.footnote.copyWith(color: c.text2),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
