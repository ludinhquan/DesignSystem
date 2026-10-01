import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/brand.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = ref.watch(brandProvider).appName;
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: ListView(
        padding: EdgeInsetsDirectional.all(context.ds.spacing.lg),
        children: [
          Text(
            'Welcome to $appName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
