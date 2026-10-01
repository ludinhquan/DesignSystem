import 'package:ds_components/ds_components.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

/// Minimal consumer of the design system with a light/dark toggle.
class ExampleApp extends StatefulWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() => setState(() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  });

  @override
  Widget build(BuildContext context) {
    // Must be the package:material_ui MaterialApp: the design system's
    // ThemeExtensions are looked up on the material_ui Theme.
    return MaterialApp(
      title: 'Design System Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: GalleryPage(
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Shows every design-system component.
class GalleryPage extends StatefulWidget {
  /// Creates the gallery page.
  const GalleryPage({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  /// Whether the dark theme is active.
  final bool isDark;

  /// Switches between light and dark.
  final VoidCallback onToggleTheme;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _saving = false;
  int _cardTaps = 0;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        actions: [
          Row(
            children: [
              Text('Dark', style: typography.label),
              Switch(
                value: widget.isDark,
                onChanged: (_) => widget.onToggleTheme(),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.all(spacing.md),
        children: [
          Text('Buttons', style: typography.headline),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              AppButton.primary(
                label: 'Save',
                isLoading: _saving,
                onPressed: _save,
              ),
              AppButton.secondary(label: 'Cancel', onPressed: () {}),
              AppButton.ghost(label: 'Learn more', onPressed: () {}),
              const AppButton.primary(label: 'Disabled', onPressed: null),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final size in AppButtonSize.values)
                AppButton(
                  label: 'Size ${size.name}',
                  size: size,
                  icon: Icons.add,
                  onPressed: () {},
                ),
            ],
          ),
          SizedBox(height: spacing.xl),
          Text('Cards', style: typography.headline),
          SizedBox(height: spacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Static card', style: typography.title),
                SizedBox(height: spacing.xs),
                Text(
                  'Surfaces, borders, radii and text all come from tokens.',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          AppCard(
            onTap: () => setState(() => _cardTaps++),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tappable card', style: typography.title),
                SizedBox(height: spacing.xs),
                Text('Tapped $_cardTaps times'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
