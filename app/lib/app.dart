import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'config/brand.dart';
import 'features/home/ui/home_screen.dart';
import 'l10n/l10n.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(
      onGenerateTitle: (_) => brand.appName,
      theme: DsTheme.light(brand.ds),
      darkTheme: DsTheme.dark(brand.ds),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
