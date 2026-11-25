import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/rail_entities.dart';
import '../../services/settings_store.dart';
import '../../shared/config.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/formatters.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final fmt = Fmt(s.language);
    final bundle = ref.watch(railBundleProvider);
    final stations = bundle.network.stations.values;
    final withBn = stations.where((x) => x.hasBanglaName).length;
    final theme = Theme.of(context);

    Widget header(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(t, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(children: [
        header(l.language),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'bn', label: Text(l.bangla)),
              ButtonSegment(value: 'en', label: Text(l.english)),
            ],
            selected: {s.language},
            onSelectionChanged: (v) => n.update((x) => x.copyWith(language: v.first)),
          ),
        ),
        header(l.theme),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AppThemeMode>(
            segments: [
              ButtonSegment(value: AppThemeMode.system, label: Text(l.themeSystem)),
              ButtonSegment(value: AppThemeMode.light, label: Text(l.themeLight)),
              ButtonSegment(value: AppThemeMode.dark, label: Text(l.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => n.update((x) => x.copyWith(themeMode: v.first)),
          ),
        ),
        header(l.mapOverlays),
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
        if (FeatureFlags.audio) ...[
          header(l.soundEffects),
          SwitchListTile(
              title: Text(l.soundEffects),
              subtitle: Text(l.soundEffectsDesc),
              value: s.soundEnabled,
              onChanged: (v) => n.update((x) => x.copyWith(soundEnabled: v))),
        ],
        header(l.networkTitle),
        ListTile(
          leading: const Icon(Icons.wifi_off),
          title: Text(l.offlineNote),
        ),
        ListTile(
          leading: const Icon(Icons.settings_ethernet),
          title: Text(l.openNetworkSettings),
          onTap: () async {
            final ok = await ref.read(platformSettingsProvider).openInternetSettings();
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.networkSettingsFailed)));
            }
          },
        ),
        header(l.about),
        ListTile(
          leading: const Icon(Icons.map_outlined),
          title: Text(l.dataAttribution),
          subtitle: Text(bundle.network.info.attribution.isEmpty
              ? l.mapAttribution
              : bundle.network.info.attribution),
        ),
        ListTile(
          leading: const Icon(Icons.dataset),
          title: Text(l.datasetSummary(
              fmt.digits(stations.length),
              fmt.digits(bundle.network.segments.length),
              fmt.digits(bundle.network.bridges.length),
              fmt.digits(bundle.places.length),
              fmt.digits(bundle.roads.length))),
          subtitle: Text([
            if (bundle.network.info.generated != null)
              l.datasetGenerated(fmt.digits(bundle.network.info.generated!)),
            l.banglaCoverage(fmt.digits(withBn), fmt.digits(stations.length)),
            if (bundle.issues.isNotEmpty) l.parseIssues(fmt.digits(bundle.issues.length)),
            '${NameSource.datasetExact.name}/${NameSource.curated.name}',
          ].join('\n')),
          isThreeLine: true,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l.disclaimer, style: theme.textTheme.bodySmall),
        ),
      ]),
    );
  }
}
