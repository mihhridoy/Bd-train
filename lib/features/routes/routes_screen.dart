import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/rail_route.dart';
import '../../domain/usecases/search_index.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/formatters.dart';
import '../search/search_page.dart';

/// Computes the shortest track path between two stations and shows it.
class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, bool origin) async {
    final hit = await Navigator.of(context).push<SearchHit>(
        MaterialPageRoute(builder: (_) => const SearchPage(stationsOnly: true)));
    if (hit is StationHit) {
      (origin ? ref.read(routeOriginProvider.notifier) : ref.read(routeDestinationProvider.notifier))
          .set(hit.station.key);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final fmt = Fmt(lang);
    final net = ref.watch(networkProvider);
    final from = ref.watch(routeOriginProvider);
    final to = ref.watch(routeDestinationProvider);
    final theme = Theme.of(context);

    RailRoute? route;
    var noPath = false;
    if (from != null && to != null) {
      route = ref.watch(routeFinderProvider).find(from, to);
      noPath = route == null;
    }
    String nameOf(String k) => net.station(k)?.displayName(lang) ?? k;

    Widget picker(String label, String? key, IconData icon, bool origin) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pick(context, ref, origin),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
            ),
            child: Text(key == null ? l.selectStation : nameOf(key),
                style: key == null
                    ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
                    : null),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.navRoutes)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(
              child: Column(children: [
                picker(l.routeFrom, from, Icons.trip_origin, true),
                const SizedBox(height: 12),
                picker(l.routeTo, to, Icons.flag, false),
              ]),
            ),
            IconButton(
              tooltip: l.swap,
              icon: const Icon(Icons.swap_vert),
              onPressed: () {
                ref.read(routeOriginProvider.notifier).set(to);
                ref.read(routeDestinationProvider.notifier).set(from);
              },
            ),
          ]),
          const SizedBox(height: 16),
          if (noPath)
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.routeNoPath))),
          if (route != null) ...[
            _RouteSummary(route: route),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.map),
                  label: Text(l.showOnMap),
                  onPressed: () {
                    ref.read(activeRouteProvider.notifier).set(route);
                    ref.read(homeTabProvider.notifier).go(HomeTab.map);
                    ref.read(mapCommandProvider.notifier).send(MapCommand.fitRoute(route!));
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  ref.read(activeRouteProvider.notifier).set(null);
                  ref.read(routeOriginProvider.notifier).set(null);
                  ref.read(routeDestinationProvider.notifier).set(null);
                },
                child: Text(l.clearRoute),
              ),
            ]),
            const SizedBox(height: 16),
            Text(l.routeStations, style: theme.textTheme.titleMedium),
            Text(l.routeStationsNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            for (var i = 0; i < route.along.length; i++)
              _StopTile(
                  name: nameOf(route.along[i].key),
                  first: i == 0,
                  last: i == route.along.length - 1,
                  distanceFromPrev: i == 0
                      ? null
                      : fmt.distance(route.along[i].atMeters - route.along[i - 1].atMeters)),
            if (route.bridges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l.routeBridges, style: theme.textTheme.titleMedium),
              for (final b in route.bridges)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(b.hasName ? b.displayName(lang) : l.unnamedBridge),
                  trailing: Text(fmt.distance(b.lengthMeters.toDouble())),
                ),
            ],
            const SizedBox(height: 16),
            Text(l.routeNote, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _RouteSummary extends ConsumerWidget {
  const _RouteSummary({required this.route});
  final RailRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt(ref.watch(languageProvider));
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.routeDistance, style: theme.textTheme.labelMedium),
              Text(fmt.distance(route.totalMeters), style: theme.textTheme.headlineMedium),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(l.stopsCount(fmt.digits(route.stopCount))),
            Text('${fmt.digits(route.bridges.length)} ${l.layerBridges}'),
          ]),
        ]),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile(
      {required this.name, required this.first, required this.last, this.distanceFromPrev});
  final String name;
  final bool first, last;
  final String? distanceFromPrev;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return IntrinsicHeight(
      child: Row(children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            Expanded(child: Container(width: 2, color: first ? Colors.transparent : color)),
            Container(
              width: first || last ? 14 : 8,
              height: first || last ? 14 : 8,
              decoration: BoxDecoration(
                  color: first || last ? color : Theme.of(context).colorScheme.surface,
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle),
            ),
            Expanded(child: Container(width: 2, color: last ? Colors.transparent : color)),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(name,
                style: first || last ? const TextStyle(fontWeight: FontWeight.w700) : null),
          ),
        ),
        if (distanceFromPrev != null)
          Text(distanceFromPrev!, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
