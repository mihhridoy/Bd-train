import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/rail_entities.dart';
import '../../domain/entities/train.dart';
import '../../domain/usecases/search_index.dart';
import '../../services/location_service.dart';
import '../../shared/config.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../search/search_page.dart';
import '../station/station_sheet.dart';
import '../tracking/train_sheet.dart';
import 'widgets/layers_sheet.dart';
import 'widgets/map_layers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _controller = MapController();
  bool _ready = false;

  static final _bangladeshCenter = const LatLng(23.8, 90.3);
  static final _bounds = LatLngBounds(const LatLng(20.0, 87.4), const LatLng(27.2, 93.2));

  void _apply(MapCommand cmd) {
    if (!_ready) return;
    final route = cmd.route;
    if (route != null) {
      _controller.fitCamera(CameraFit.coordinates(
        coordinates: [for (final p in route.polyline) toLatLng(p)],
        padding: const EdgeInsets.fromLTRB(40, 140, 40, 100),
        maxZoom: 13,
      ));
    } else if (cmd.point != null) {
      _controller.move(toLatLng(cmd.point!), cmd.zoom);
    }
  }

  Future<void> _openSearch() async {
    final hit = await Navigator.of(context)
        .push<SearchHit>(MaterialPageRoute(builder: (_) => const SearchPage()));
    if (hit == null || !mounted) return;
    switch (hit) {
      case StationHit(:final station):
        _openStation(station.key);
      case PlaceHit(:final place):
        _openPlace(place);
    }
  }

  void _openStation(String key) {
    final net = ref.read(networkProvider);
    final s = net.station(key);
    if (s == null) return;
    ref.read(selectedStationProvider.notifier).set(key);
    final z = _ready ? _controller.camera.zoom : 0.0;
    _apply(MapCommand.focus(s.position, zoom: z < 11.5 ? 12 : z));
    showStationSheet(context, key).whenComplete(() {
      if (mounted && ref.read(selectedStationProvider) == key) {
        ref.read(selectedStationProvider.notifier).set(null);
      }
    });
  }

  void _openPlace(Place p) {
    _apply(MapCommand.focus(p.position, zoom: 12.5));
    showPlaceSheet(context, p, onOpenStation: _openStation);
  }

  void _showBridge(RailBridge b) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt(ref.read(languageProvider));
    final name = b.hasName ? b.displayName(ref.read(languageProvider)) : l.unnamedBridge;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('$name · ${l.bridgeLength(fmt.distance(b.lengthMeters.toDouble()))}')));
  }

  Future<void> _locate() async {
    final l = AppLocalizations.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.my_location),
        title: Text(l.locationWhyTitle),
        content: Text(l.locationWhyBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.allow)),
        ],
      ),
    );
    if (proceed != true || !mounted) return;
    final outcome = await ref.read(locationServiceProvider).getCurrentLocation();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    switch (outcome) {
      case LocationGranted(:final point):
        ref.read(userLocationProvider.notifier).set(point);
        _apply(MapCommand.focus(point, zoom: 11));
        final net = ref.read(networkProvider);
        final near = net.nearestStations(point, limit: 1).first;
        final lang = ref.read(languageProvider);
        messenger.showSnackBar(SnackBar(
          content: Text(l.nearestToYou(
              near.station.displayName(lang), Fmt(lang).distance(near.distanceMeters))),
          action: SnackBarAction(label: l.showOnMap, onPressed: () => _openStation(near.station.key)),
        ));
      case LocationDenied():
        messenger.showSnackBar(SnackBar(content: Text(l.locationDenied)));
      case LocationDeniedForever():
        messenger.showSnackBar(SnackBar(
          content: Text(l.locationDeniedForever),
          action: SnackBarAction(
              label: l.openSettings,
              onPressed: () => ref.read(locationServiceProvider).openAppSettings()),
        ));
      case LocationServiceOff():
        messenger.showSnackBar(SnackBar(content: Text(l.locationServiceOff)));
      case LocationFailed():
        messenger.showSnackBar(SnackBar(content: Text(l.locationFailed)));
    }
  }

  void _zoomBy(double d) {
    if (!_ready) return;
    final cam = _controller.camera;
    _controller.move(cam.center, (cam.zoom + d).clamp(5.5, 18));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = MapPalette.of(context);
    final settings = ref.watch(settingsProvider);
    final route = ref.watch(activeRouteProvider);
    final lang = ref.watch(languageProvider);
    final demo = ref.watch(demoEnabledProvider);

    ref.listen<MapCommand?>(mapCommandProvider, (_, cmd) {
      if (cmd == null) return;
      _apply(cmd);
      ref.read(mapCommandProvider.notifier).consume();
    });

    final theme = Theme.of(context);
    final net = ref.watch(networkProvider);

    return Stack(children: [
      FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: _bangladeshCenter,
          initialZoom: 7,
          minZoom: 5.5,
          maxZoom: 18,
          backgroundColor: palette.land,
          cameraConstraint: CameraConstraint.containCenter(bounds: _bounds),
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          onMapReady: () => _ready = true,
          onTap: (_, _) => ref.read(selectedStationProvider.notifier).set(null),
        ),
        children: [
          if (AppConfig.tilesConfigured && settings.showBaseTiles)
            TileLayer(
              urlTemplate: AppConfig.tileUrlTemplate,
              userAgentPackageName: 'dev.bdrail.bd_train_tracker',
            ),
          if (settings.showRoads) const RoadsLayer(),
          const RailLayer(),
          if (settings.showBridges) BridgeLayer(onTap: _showBridge),
          const RouteLayer(),
          if (settings.showPlaces) PlacesLayer(onTap: _openPlace),
          StationLayer(onTap: (s) => _openStation(s.key)),
          if (demo)
            DemoTrainLayer(
              badge: l.demoBadge,
              onTap: (t) => showTrainSheet(context, t),
            ),
          const UserLocationLayer(),
        ],
      ),
      Positioned(
        left: 8,
        bottom: 8,
        right: 76, // keep clear of the map buttons
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              [
                l.mapAttribution,
                if (AppConfig.tilesConfigured && settings.showBaseTiles && AppConfig.tileAttribution.isNotEmpty)
                  AppConfig.tileAttribution,
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Material(
              elevation: 3,
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _openSearch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(l.searchHint,
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
                    Icon(Icons.cloud_off, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  ]),
                ),
              ),
            ),
            if (demo) ...[
              const SizedBox(height: 8),
              const _DemoMapBanner(),
            ],
            if (route != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: const Icon(Icons.alt_route, size: 18),
                  label: Text(l.routeActive(
                      net.station(route.originKey)?.displayName(lang) ?? route.originKey,
                      net.station(route.destinationKey)?.displayName(lang) ?? route.destinationKey)),
                  onPressed: () => _apply(MapCommand.fitRoute(route)),
                  onDeleted: () => ref.read(activeRouteProvider.notifier).set(null),
                  deleteButtonTooltipMessage: l.clearRoute,
                ),
              ),
            ],
          ]),
        ),
      ),
      Positioned(
        right: 12,
        bottom: 24,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _MapButton(icon: Icons.layers, tooltip: l.layers, onPressed: () => showLayersSheet(context)),
          if (FeatureFlags.location) ...[
            const SizedBox(height: 8),
            _MapButton(icon: Icons.my_location, tooltip: l.myLocation, onPressed: _locate),
          ],
          const SizedBox(height: 8),
          _MapButton(icon: Icons.add, tooltip: l.zoomIn, onPressed: () => _zoomBy(1)),
          const SizedBox(height: 8),
          _MapButton(icon: Icons.remove, tooltip: l.zoomOut, onPressed: () => _zoomBy(-1)),
        ]),
      ),
    ]);
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
        heroTag: null,
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(icon),
      );
}

/// Persistent on-map label while demo mode is active, plus stale warning.
class _DemoMapBanner extends ConsumerWidget {
  const _DemoMapBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final palette = MapPalette.of(context);
    final fmt = Fmt(ref.watch(languageProvider));
    final snap = ref.watch(trainSnapshotProvider).value;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final fresh = ref.watch(stalenessPolicyProvider).evaluate(snap?.fetchedAt, now);
    final stale = fresh == Freshness.stale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: palette.demo, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.science, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            stale && snap != null
                ? '${l.demoBanner}\n${l.staleBanner(fmt.digits(now.difference(snap.fetchedAt).inSeconds))}'
                : l.demoBanner,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}
