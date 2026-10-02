import 'package:material_ui/material_ui.dart';

import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_ground.dart';
import '../theme/ds_tokens.dart';

/// A filled, outline-less text field: label above, helper or error below,
/// and a 1.5px ink ring while editing. The error adds a `negative` ring, a
/// glyph and a sentence that says how to fix it.
///
/// Use `DsAmountField` for money.
class DsTextField extends StatefulWidget {
  const DsTextField({
    required this.label,
    this.controller,
    this.placeholder,
    this.helper,
    this.error,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.inputKey,
    super.key,
  });

  final String label;
  final TextEditingController? controller;

  /// An example value, never the label.
  final String? placeholder;
  final String? helper;
  final String? error;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Key for the editable text itself (tests enter text through it).
  final Key? inputKey;

  @override
  State<DsTextField> createState() => _DsTextFieldState();
}

class _DsTextFieldState extends State<DsTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _focus.dispose();
    _controller.removeListener(_rebuild);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final error = widget.error;
    final ring = error != null
        ? BorderSide(color: c.negative, width: 1.5)
        : _focus.hasFocus
        ? BorderSide(color: c.focusRing, width: 1.5)
        : BorderSide.none;
    final shape = ds.shape(ds.radius.tile, side: ring);
    final showClear =
        widget.enabled && !widget.obscureText && _controller.text.isNotEmpty;

    return Opacity(
      opacity: widget.enabled ? 1 : ds.opacity.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: ds.text.label.copyWith(color: c.text2),
            ),
          ),
          SizedBox(height: ds.spacing.s2),
          DsBox(
            shape: shape,
            color: DsGround.chrome(context),
            shadow: ds.shadows.surface,
            child: SizedBox(
              height: ds.size.fieldHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: ds.spacing.s4,
                        end: showClear ? 0 : ds.spacing.s4,
                      ),
                      // The visible label above names the field for screen
                      // readers through this node.
                      child: Semantics(
                        label: widget.label,
                        child: TextField(
                          key: widget.inputKey,
                          controller: _controller,
                          focusNode: _focus,
                          enabled: widget.enabled,
                          obscureText: widget.obscureText,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          autofillHints: widget.autofillHints,
                          onChanged: widget.onChanged,
                          onSubmitted: widget.onSubmitted,
                          style: ds.text.callout.copyWith(color: c.text1),
                          cursorColor: c.accentText,
                          decoration: InputDecoration.collapsed(
                            hintText: widget.placeholder,
                            hintStyle: ds.text.callout.copyWith(color: c.text3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showClear)
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(context)
                          .deleteButtonTooltip,
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        child: SizedBox.square(
                          dimension: ds.size.hitTarget,
                          child: Center(
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: c.text3,
                                shape: BoxShape.circle,
                              ),
                              child: DsGlyph(
                                ds.icons.close,
                                weight: DsGlyphWeight.bold,
                                size: 11,
                                color: DsGround.chrome(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (error != null || widget.helper != null) ...[
            SizedBox(height: ds.spacing.s2),
            Semantics(
              liveRegion: error != null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null) ...[
                    DsGlyph(
                      ds.icons.warning,
                      weight: DsGlyphWeight.fill,
                      size: 16,
                      color: c.negative,
                    ),
                    SizedBox(width: ds.spacing.s1),
                  ],
                  Expanded(
                    child: Text(
                      error ?? widget.helper!,
                      style: ds.text.footnote.copyWith(
                        color: error != null ? c.negative : c.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
