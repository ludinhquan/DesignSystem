import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../theme/ds_tokens.dart';
import 'ds_icon_button.dart';
import 'ds_monogram.dart';

enum _NavKind { home, large, inline }

/// The top of a screen.
///
/// * [DsNavigationBar.home]: avatar, greeting and name. Home only; the
///   balance is the headline, so there is no large title.
/// * [DsNavigationBar.large]: a display-face title for root tabs.
/// * [DsNavigationBar.inline]: a centred title for pushed screens; it turns
///   glass with a hairline once content scrolls under it ([scrolled]).
///
/// Home and large sit at the top of the scroll content; inline goes in
/// `Scaffold.appBar`.
class DsNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const DsNavigationBar.home({
    required String this.initials,
    required String this.greeting,
    required String this.name,
    this.actions = const [],
    super.key,
  }) : title = null,
       onBack = null,
       scrolled = false,
       _kind = _NavKind.home;

  const DsNavigationBar.large({
    required String this.title,
    this.actions = const [],
    super.key,
  }) : initials = null,
       greeting = null,
       name = null,
       onBack = null,
       scrolled = false,
       _kind = _NavKind.large;

  const DsNavigationBar.inline({
    required String this.title,
    this.onBack,
    this.actions = const [],
    this.scrolled = false,
    super.key,
  }) : initials = null,
       greeting = null,
       name = null,
       _kind = _NavKind.inline;

  final String? initials;
  final String? greeting;
  final String? name;
  final String? title;

  /// At most two `DsIconButton`s. Never a prominent button.
  final List<Widget> actions;
  final VoidCallback? onBack;

  /// Content has moved under the inline bar.
  final bool scrolled;
  final _NavKind _kind;

  static const _barHeight = 52.0;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight);

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, a) in actions.indexed) ...[
          if (i > 0) SizedBox(width: ds.spacing.s2),
          a,
        ],
      ],
    );

    switch (_kind) {
      case _NavKind.home:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: [
                DsMonogram(initials!, field: DsField.graphite),
                SizedBox(width: ds.spacing.s3),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting!,
                        style: ds.text.footnote.copyWith(color: c.text2),
                        maxLines: 1,
                      ),
                      Text(
                        name!,
                        style: ds.text.headline.copyWith(color: c.text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        );
      case _NavKind.large:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _barHeight,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                ),
              ),
              Semantics(
                header: true,
                child: Text(
                  title!,
                  style: ds.text.titleScreen.copyWith(color: c.text1),
                ),
              ),
            ],
          ),
        );
      case _NavKind.inline:
        final duration = ds.motion.fade;
        final bar = SafeArea(
          bottom: false,
          child: SizedBox(
            height: _barHeight,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: ds.spacing.s2,
              ),
              child: NavigationToolbar(
                leading: onBack == null
                    ? null
                    : DsIconButton(
                        icon: ds.icons.back,
                        label: MaterialLocalizations.of(context)
                            .backButtonTooltip,
                        variant: DsIconButtonVariant.plain,
                        onPressed: onBack,
                      ),
                middle: Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: ds.text.headline.copyWith(color: c.text1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: trailing,
              ),
            ),
          ),
        );
        final glass = scrolled && !MediaQuery.highContrastOf(context);
        return ClipRect(
          child: BackdropFilter(
            enabled: glass,
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: AnimatedContainer(
              duration: duration,
              decoration: BoxDecoration(
                color: scrolled ? (glass ? c.glass : c.surface) : c.canvas,
                border: Border(
                  bottom: BorderSide(
                    color: scrolled ? c.separator : c.separator.withAlpha(0),
                    width: 0.5,
                  ),
                ),
              ),
              child: bar,
            ),
          ),
        );
    }
  }
}
