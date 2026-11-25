import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/config.dart';
import '../../../shared/l10n/generated/app_localizations.dart';
import '../../../shared/providers.dart';

Future<void> showLayersSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const LayersSheet(),
    );

class LayersSheet extends ConsumerWidget {
  const LayersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l.layers, style: Theme.of(context).textTheme.titleLarge)),
        ),
        SwitchListTile(
            title: Text(l.layerPlaces),
            value: s.showPlaces,
            onChanged: (v) => n.update((x) => x.copyWith(showPlaces: v))),
        SwitchListTile(
            title: Text(l.layerRoads),
            value: s.showRoads,
            onChanged: (v) => n.update((x) => x.copyWith(showRoads: v))),
        SwitchListTile(
            title: Text(l.layerBridges),
            value: s.showBridges,
            onChanged: (v) => n.update((x) => x.copyWith(showBridges: v))),
        SwitchListTile(
            title: Text(l.layerLabels),
            value: s.showStationLabels,
            onChanged: (v) => n.update((x) => x.copyWith(showStationLabels: v))),
        SwitchListTile(
          title: Text(l.layerTiles),
          subtitle: AppConfig.tilesConfigured ? null : Text(l.layerTilesOff),
          value: AppConfig.tilesConfigured && s.showBaseTiles,
          onChanged: AppConfig.tilesConfigured
              ? (v) => n.update((x) => x.copyWith(showBaseTiles: v))
              : null,
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
