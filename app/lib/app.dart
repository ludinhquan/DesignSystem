import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'config/brand.dart';
import 'features/home/ui/home_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(
      title: brand.appName,
      theme: DsTheme.light(brand.ds),
      darkTheme: DsTheme.dark(brand.ds),
      localizationsDelegates: const [DsLocalizations.englishDelegate],
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
