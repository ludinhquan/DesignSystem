import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../l10n/ds_localizations.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_haptics.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';
import 'ds_money.dart';

/// What an account card shows.
@immutable
class DsCardData {
  const DsCardData({
    required this.id,
    required this.field,
    required this.name,
    required this.balance,
    this.institution,
    this.last4,
    this.shiftTo,
  });

  /// Stable id (the stack's order and keys).
  final String id;

  /// The colour the person picked for this account; it is this account's
  /// colour everywhere.
  final DsField field;

  /// The person's own name for it ("Chi tiêu hằng ngày").
  final String name;

  /// In đồng.
  final int balance;

  /// The bank as plain text. Never its logo or colours.
  final String? institution;
  final String? last4;

  /// Monthly face shift toward the dominant spending category's field.
  /// Graphite never shifts.
  final DsField? shiftTo;
}

/// Card size: the full card, or a small one for pickers.
enum DsCardSize { md, sm }

/// The signature object: an account as a physical card with a gradient
/// face, grain, a lit top edge, its own tinted shadow and a specular
/// highlight from the top left. ID-1 proportions.
class DsAccountCard extends StatelessWidget {
  const DsAccountCard({
    required this.data,
    this.size = DsCardSize.md,
    this.hidden = false,
    this.roll = false,
    this.onTap,
    this.behind = false,
    super.key,
  });

  final DsCardData data;
  final DsCardSize size;

  /// Mask the balance.
  final bool hidden;

  /// Roll the balance when it changes.
  final bool roll;
  final VoidCallback? onTap;

  /// Behind the front card of a stack: contact shadow only, 97% brightness.
  final bool behind;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final field = ds.colors.field(data.field);
    final shift = data.shiftTo == null || data.field == DsField.graphite
        ? null
        : ds.colors.field(data.shiftTo!);
    final shape = ds.shape(ds.radius.card);
    final sm = size == DsCardSize.sm;
    final l10n = DsLocalizations.of(context);
    final balanceText = hidden
        ? l10n.hiddenAmount
        : l10n.amountSemantics(
            DsMoneyFormat.digits(data.balance),
            negative: data.balance < 0,
            positive: false,
          );

    Widget face(bool pressed) {
      Widget card = AspectRatio(
        aspectRatio: ds.size.cardAspect,
        child: DsObjectFace(
          field: field,
          shape: shape,
          pressed: pressed,
          shiftTo: shift,
          shadow: behind ? ds.shadows.objectPress : null,
          padding: EdgeInsetsDirectional.all(
            sm ? ds.spacing.s3 : ds.spacing.s5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!sm && data.institution != null)
                Text(
                  data.institution!,
                  style: ds.text.footnote.copyWith(color: field.ink2),
                  maxLines: 1,
                ),
              Text(
                data.name,
                style: (sm ? ds.text.label : ds.text.headline).copyWith(
                  color: field.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.bottomStart,
                      child: DsMoney(
                        data.balance,
                        size: sm ? DsMoneySize.row : DsMoneySize.card,
                        onObject: field,
                        hidden: hidden,
                        roll: roll,
                      ),
                    ),
                  ),
                  if (!sm && data.last4 != null) ...[
                    SizedBox(width: ds.spacing.s2),
                    Text(
                      '•• ${data.last4}',
                      style: ds.text.footnote.copyWith(color: field.ink2),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
      if (behind) {
        card = ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.97, 0, 0, 0, 0, //
            0, 0.97, 0, 0, 0, //
            0, 0, 0.97, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: card,
        );
      }
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ds.size.cardMax),
        child: card,
      );
    }

    return Semantics(
      button: onTap != null,
      label: l10n.cardSemantics(
        institution: data.institution,
        name: data.name,
        balance: balanceText,
        last4: data.last4,
      ),
      excludeSemantics: true,
      child: onTap == null
          ? face(false)
          : DsPressable(
              onTap: onTap,
              object: true,
              scale: ds.motion.pressScaleCard,
              focusShape: shape,
              onPressDown: () => DsHaptics.press(context),
              builder: (context, state) => face(state.pressed),
            ),
    );
  }
}
