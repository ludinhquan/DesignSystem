import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';
import 'ds_account_card.dart';

/// A wallet of account cards, front to back. Each card behind shows a
/// `stack-peek` strip above the one in front and is 4.5% smaller per step.
/// Tapping a strip (or the top band of the stack) brings that card forward
/// on the object spring; tapping the front card opens it.
///
/// Shows at most four cards, in the person's own order.
class DsCardStack extends StatefulWidget {
  const DsCardStack({
    required this.cards,
    this.front,
    this.onChanged,
    this.onOpen,
    this.hidden = false,
    super.key,
  }) : assert(cards.length > 0);

  final List<DsCardData> cards;

  /// The front card's id. Uncontrolled (first card) when null.
  final String? front;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onOpen;
  final bool hidden;

  static const maxCards = 4;

  @override
  State<DsCardStack> createState() => _DsCardStackState();
}

class _DsCardStackState extends State<DsCardStack> {
  late String _front = widget.front ?? widget.cards.first.id;

  @override
  void didUpdateWidget(DsCardStack old) {
    super.didUpdateWidget(old);
    if (widget.front != null) _front = widget.front!;
    if (!widget.cards.any((c) => c.id == _front)) {
      _front = widget.cards.first.id;
    }
  }

  void _bringForward(String id) {
    if (id == _front) return;
    DsHaptics.selection(context);
    setState(() => _front = id);
    widget.onChanged?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final cards = widget.cards.take(DsCardStack.maxCards).toList();
    final front = cards.firstWhere(
      (c) => c.id == _front,
      orElse: () => cards.first,
    );
    // Depth 0 is the front card; the rest keep the person's order behind it.
    final byDepth = [front, ...cards.where((c) => c.id != front.id)];
    final n = byDepth.length;
    final peek = ds.size.stackPeek;
    final spring = ds.motion.object;
    final duration = context.dsReduceMotion ? Duration.zero : spring.duration;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, ds.size.cardMax);
        final height = width / ds.size.cardAspect;
        final band = math.max(ds.size.hitTarget, peek * (n - 1));
        return SizedBox(
          width: width,
          height: height + peek * (n - 1),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Painted deepest first so the front card is on top.
              for (final card
                  in cards..sort(
                    (a, b) => byDepth.indexOf(b).compareTo(byDepth.indexOf(a)),
                  ))
                () {
                  final depth = byDepth.indexOf(card);
                  return AnimatedPositioned(
                    key: ValueKey(card.id),
                    duration: duration,
                    curve: spring.curve,
                    left: 0,
                    width: width,
                    top: peek * (n - 1 - depth),
                    height: height,
                    child: AnimatedScale(
                      duration: duration,
                      curve: spring.curve,
                      scale: 1 - 0.045 * depth,
                      alignment: Alignment.topCenter,
                      child: DsAccountCard(
                        data: card,
                        hidden: widget.hidden,
                        behind: depth > 0,
                        onTap: depth == 0
                            ? (widget.onOpen == null
                                  ? null
                                  : () => widget.onOpen!(card.id))
                            : () => _bringForward(card.id),
                      ),
                    ),
                  );
                }(),
              // The strips are below the tap-target size on their own: the
              // top band of the stack is split between the cards behind.
              if (n > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: band,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (d) {
                        final slice = band / (n - 1);
                        final i = (d.localPosition.dy / slice).floor().clamp(
                          0,
                          n - 2,
                        );
                        _bringForward(byDepth[n - 1 - i].id);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
