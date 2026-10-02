import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_icons.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';

/// One destination of a [DsTabBar].
@immutable
class DsTabItem {
  const DsTabItem({required this.icon, required this.label});

  final DsIcon icon;

  /// One word. Shown in the selected pill, otherwise the accessible name.
  final String label;
}

/// The floating glass capsule at the bottom of root screens. The selected
/// tab is an accent pill holding its fill glyph and label; it grows into a
/// new tab on the snappy spring. Hidden on pushed screens and sheets.
///
/// Put it in a `Stack` over the content, with [DsTabBarFade] under it and
/// `tabbar-fade` of bottom padding on scroll content.
class DsTabBar extends StatelessWidget {
  const DsTabBar({
    required this.items,
    required this.index,
    required this.onChanged,
    super.key,
  }) : assert(items.length >= 3 && items.length <= 5);

  final List<DsTabItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final shape = ds.shape(ds.radius.full);
    final reduce = context.dsReduceMotion;
    final spring = ds.motion.snappy;
    final glass = !MediaQuery.highContrastOf(context);
    final bottom = math.max(26.0, MediaQuery.paddingOf(context).bottom);

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (i, item) in items.indexed)
          Semantics(
            button: true,
            selected: i == index,
            label: item.label,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (i == index) return;
                DsHaptics.selection(context);
                onChanged(i);
              },
              child: AnimatedSize(
                duration: reduce ? Duration.zero : spring.duration,
                curve: spring.curve,
                child: i == index
                    ? DsBox(
                        shape: shape,
                        color: c.accent,
                        shadow: ds.shadows.accent,
                        child: SizedBox(
                          height: ds.size.tabPill,
                          child: Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: ds.spacing.s4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SwapIn(
                                  child: DsGlyph(
                                    item.icon,
                                    weight: DsGlyphWeight.fill,
                                    size: ds.size.iconTab,
                                    color: c.onAccent,
                                  ),
                                ),
                                SizedBox(width: ds.spacing.s2),
                                Text(
                                  item.label,
                                  style: ds.text.tabLabel.copyWith(
                                    color: c.onAccent,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: ds.size.hitTarget + ds.spacing.s1,
                        height: ds.size.tabPill,
                        child: Center(
                          child: DsGlyph(
                            item.icon,
                            size: ds.size.iconTab,
                            color: c.text1,
                          ),
                        ),
                      ),
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: ds.spacing.s4,
        end: ds.spacing.s4,
        bottom: bottom,
      ),
      child: DsBox(
        shape: shape,
        shadow: ds.shadows.glass,
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: shape),
          child: BackdropFilter(
            enabled: glass,
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: ColoredBox(
              color: glass ? c.glass : c.surface,
              child: Padding(
                padding: EdgeInsetsDirectional.all(ds.spacing.s2),
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The new tab's fill glyph swaps in: fade and scale 0.85 → 1 over 120ms.
class _SwapIn extends StatelessWidget {
  const _SwapIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.dsReduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 120),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
      ),
      child: child,
    );
  }
}

/// The canvas fade under the floating tab bar, so rows never collide with
/// the glass.
class DsTabBarFade extends StatelessWidget {
  const DsTabBarFade({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return IgnorePointer(
      child: Container(
        height: ds.size.tabbarFade,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ds.colors.canvas.withAlpha(0), ds.colors.canvas],
          ),
        ),
      ),
    );
  }
}
