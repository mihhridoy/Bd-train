import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/rail_entities.dart';
import '../../shared/config.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/formatters.dart';

String placeKindLabel(AppLocalizations l, PlaceCategory c) => switch (c) {
      PlaceCategory.city => l.kindCity,
      PlaceCategory.town => l.kindTown,
      PlaceCategory.suburb => l.kindSuburb,
      PlaceCategory.village => l.kindVillage,
      PlaceCategory.other => l.kindOther,
    };

Future<void> showStationSheet(BuildContext context, String stationKey) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => StationSheet(stationKey: stationKey, controller: scroll),
    ),
  );
}

class StationSheet extends ConsumerWidget {
  const StationSheet({super.key, required this.stationKey, required this.controller});
  final String stationKey;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final fmt = Fmt(lang);
    final net = ref.watch(networkProvider);
    final station = net.station(stationKey);
    if (station == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final edges = [...net.edgesOf(stationKey)]
      ..sort((a, b) => a.segment.lengthMeters.compareTo(b.segment.lengthMeters));
    final bridges = net.bridgesNear(station.position, 3000);
    final secondary = lang == 'bn' ? station.nameEn : (station.nameBn ?? '');
    final kind = net.isJunction(stationKey)
        ? l.junction
        : net.degree(stationKey) == 1
            ? l.terminus
            : l.kindStation;

    void goRoute(bool from) {
      if (from) {
        ref.read(routeOriginProvider.notifier).set(stationKey);
      } else {
        ref.read(routeDestinationProvider.notifier).set(stationKey);
      }
      Navigator.of(context).pop();
      ref.read(homeTabProvider.notifier).go(HomeTab.routes);
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.train, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(station.displayName(lang), style: theme.textTheme.headlineSmall),
              if (secondary.isNotEmpty && secondary != station.displayName(lang))
                Text(secondary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: [
                Chip(label: Text(kind), visualDensity: VisualDensity.compact),
                Chip(
                    label: Text(l.connectionsCount(fmt.digits(net.degree(stationKey)))),
                    visualDensity: VisualDensity.compact),
              ]),
            ]),
          ),
        ]),
        if (lang == 'bn' && !station.hasBanglaName)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.banglaNameUnavailable, style: theme.textTheme.bodySmall),
          ),
        if (station.hasBanglaName && station.nameSource != NameSource.unavailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              station.nameSource == NameSource.curated ? l.nameCurated : l.nameFromDataset,
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(
              onPressed: () => goRoute(true),
              icon: const Icon(Icons.trip_origin),
              label: Text(l.routeFromHere)),
          FilledButton.tonalIcon(
              onPressed: () => goRoute(false),
              icon: const Icon(Icons.flag),
              label: Text(l.routeToHere)),
          if (FeatureFlags.share)
            OutlinedButton.icon(
              onPressed: () => ref.read(shareServiceProvider).shareText(
                    l.shareStationText(
                        station.displayName(lang),
                        station.position.lat.toStringAsFixed(5),
                        station.position.lng.toStringAsFixed(5)),
                  ),
              icon: const Icon(Icons.share),
              label: Text(l.share),
            ),
        ]),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.my_location),
          title: Text(l.coordinates),
          subtitle: SelectableText(fmt.coordinate(station.position)),
        ),
        const Divider(),
        Text(l.connectedStations, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final e in edges)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.arrow_right_alt),
            title: Text(net.station(e.to)?.displayName(lang) ?? e.to),
            trailing: Text(fmt.distance(e.segment.lengthMeters)),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(selectedStationProvider.notifier).set(e.to);
              ref.read(mapCommandProvider.notifier)
                  .send(MapCommand.focus(net.station(e.to)!.position, zoom: 12));
              showStationSheet(context, e.to);
            },
          ),
        if (bridges.isNotEmpty) ...[
          const Divider(),
          Text(l.nearbyBridges, style: theme.textTheme.titleMedium),
          for (final b in bridges)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.swap_horiz),
              title: Text(b.hasName ? b.displayName(lang) : l.unnamedBridge),
              trailing: Text(fmt.distance(b.lengthMeters.toDouble())),
            ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l.mapAttribution, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// Small sheet for a tapped place: shows the nearest station.
Future<void> showPlaceSheet(BuildContext context, Place place,
    {required void Function(String stationKey) onOpenStation}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Consumer(builder: (ctx, ref, _) {
      final l = AppLocalizations.of(ctx);
      final lang = ref.watch(languageProvider);
      final fmt = Fmt(lang);
      final net = ref.watch(networkProvider);
      final nearest = net.nearestStations(place.position, limit: 1).first;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.displayName(lang), style: Theme.of(ctx).textTheme.headlineSmall),
            Text(placeKindLabel(l, place.category)),
            const SizedBox(height: 4),
            Text(fmt.coordinate(place.position), style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.train),
              title: Text(l.nearestStationTo(
                  nearest.station.displayName(lang), fmt.distance(nearest.distanceMeters))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(ctx).pop();
                onOpenStation(nearest.station.key);
              },
            ),
          ]),
        ),
      );
    }),
  );
}
