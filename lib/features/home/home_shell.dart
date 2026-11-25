import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../map/map_screen.dart';
import '../routes/routes_screen.dart';
import '../settings/settings_screen.dart';
import '../tracking/trains_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tab = ref.watch(homeTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: const [
          MapScreen(),
          RoutesScreen(),
          TrainsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) =>
            ref.read(homeTabProvider.notifier).go(HomeTab.values[i]),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: l.navMap),
          NavigationDestination(
              icon: const Icon(Icons.alt_route),
              selectedIcon: const Icon(Icons.alt_route),
              label: l.navRoutes),
          NavigationDestination(
              icon: const Icon(Icons.train_outlined),
              selectedIcon: const Icon(Icons.train),
              label: l.navTrains),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.navSettings),
        ],
      ),
    );
  }
}
