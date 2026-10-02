import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../primitives/ds_box.dart';
import '../theme/ds_tokens.dart';

/// Initials in a circle: a `surface` disc for people and merchants, or an
/// object face (the graphite avatar on Home) when [field] is set.
class DsMonogram extends StatelessWidget {
  const DsMonogram(this.initials, {this.field, this.size, super.key});

  /// One or two letters.
  final String initials;
  final DsField? field;

  /// Defaults to `avatar` (40).
  final double? size;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final d = size ?? ds.size.avatar;
    final f = field == null ? null : ds.colors.field(field!);
    final label = Text(
      initials,
      style: ds.text.monogram.copyWith(color: f?.ink ?? ds.colors.text1),
      maxLines: 1,
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: d,
        child: f == null
            ? DsBox(
                shape: const CircleBorder(),
                color: ds.colors.surface,
                shadow: ds.shadows.surface,
                child: Center(child: label),
              )
            : DsObjectFace(
                field: f,
                shape: const CircleBorder(),
                grain: false,
                child: Center(child: label),
              ),
      ),
    );
  }
}
