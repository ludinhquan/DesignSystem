import 'package:ds_components/ds_components.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// [AppButton] with knobs for every public parameter.
Widget appButtonUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return AppButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
    variant: context.knobs.object.dropdown(
      label: 'Variant',
      options: AppButtonVariant.values,
      labelBuilder: (v) => v.name,
    ),
    size: context.knobs.object.dropdown(
      label: 'Size',
      options: AppButtonSize.values,
      initialOption: AppButtonSize.md,
      labelBuilder: (s) => s.name,
    ),
    icon: context.knobs.boolean(label: 'Icon') ? Icons.add : null,
    isLoading: context.knobs.boolean(label: 'Loading'),
    onPressed: enabled ? () {} : null,
  );
}
