import 'package:ds_components/ds_components.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// [AppCard] with editable content.
Widget appCardUseCase(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Card');
  final body = context.knobs.string(
    label: 'Body',
    initialValue: 'Cards use surfaceRaised, borderDefault and radius.lg.',
    maxLines: 3,
  );
  final tappable = context.knobs.boolean(label: 'Tappable', initialValue: true);

  return Padding(
    padding: EdgeInsetsDirectional.all(context.spacing.md),
    child: AppCard(
      onTap: tappable ? () {} : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.title),
          SizedBox(height: context.spacing.xs),
          Text(body),
        ],
      ),
    ),
  );
}
