import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/entities/geo.dart';
import '../../../domain/entities/rail_entities.dart';
import '../../../domain/entities/train.dart';
import '../../../shared/providers.dart';
import '../../../shared/theme/app_theme.dart';

LatLng toLatLng(GeoPoint p) => LatLng(p.lat, p.lng);

/// Screen-space declutter: keeps at most one item per [cell]-pixel grid cell,
/// so dense areas stay readable. Callers feed items most-important-first.
class _Declutter {
  _Declutter(this.camera, this.cellW, [double? cellH]) : cellH = cellH ?? cellW;
  final MapCamera camera;
  final double cellW, cellH;
  final Set<int> _used = {};

  bool take(GeoPoint p) {
    final o = camera.getOffsetFromOrigin(toLatLng(p));
    final cx = (o.dx / cellW).floor(), cy = (o.dy / cellH).floor();
    return _used.add(cx * 100003 + cy);
  }
}

/// Places ordered most-important-first so zoom-based caps keep cities visible.
final _sortedPlacesProvider = Provider<List<Place>>((ref) {
  final list = [...ref.watch(railBundleProvider).places];
  list.sort((a, b) => a.category.index.compareTo(b.category.index));
  return list;
});

/// Roads drawn faintly under everything else. Hidden at low zoom for clarity
/// and speed; flutter_map culls and simplifies off-screen/over-detailed lines.
class RoadsLayer extends ConsumerWidget {
  const RoadsLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = MapCamera.of(context).zoom;
    if (zoom < 8) return const SizedBox.shrink();
    final palette = MapPalette.of(context);
    final geo = ref.watch(mapGeometryProvider);
    return _CachedPolylines(
      key: ValueKey('roads-${palette.road}'),
      build: () => [
        for (final pts in geo.roads)
          Polyline(points: pts, strokeWidth: 1.6, color: palette.road),
      ],
    );
  }
}

/// Track geometry: dark casing with a light centre dash, railway-style.
class RailLayer extends ConsumerWidget {
  const RailLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = MapPalette.of(context);
    final geo = ref.watch(mapGeometryProvider);
    final zoom = MapCamera.of(context).zoom;
    final detailed = zoom >= 9;
    return Stack(children: [
      _CachedPolylines(
        key: ValueKey('rail-casing-${palette.railCasing}-$detailed'),
        build: () => [
          for (final pts in geo.rail)
            Polyline(
                points: pts,
                strokeWidth: detailed ? 4.5 : 3,
                color: palette.railCasing,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round),
        ],
      ),
      if (detailed)
        _CachedPolylines(
          key: ValueKey('rail-core-${palette.railCore}'),
          build: () => [
            for (final pts in geo.rail)
              Polyline(
                  points: pts,
                  strokeWidth: 1.6,
                  color: palette.railCore,
                  pattern: StrokePattern.dashed(segments: const [7, 7])),
          ],
        ),
    ]);
  }
}

/// Caches the (large) Polyline list so it is not rebuilt on every camera move.
class _CachedPolylines extends StatefulWidget {
  const _CachedPolylines({super.key, required this.build});
  final List<Polyline> Function() build;

  @override
  State<_CachedPolylines> createState() => _CachedPolylinesState();
}

class _CachedPolylinesState extends State<_CachedPolylines> {
  late final List<Polyline> _lines = widget.build();

  @override
  Widget build(BuildContext context) =>
      PolylineLayer(polylines: _lines, simplificationTolerance: 0.6);
}

class RouteLayer extends ConsumerWidget {
  const RouteLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(activeRouteProvider);
    if (route == null) return const SizedBox.shrink();
    final palette = MapPalette.of(context);
    final pts = [for (final p in route.polyline) toLatLng(p)];
    return PolylineLayer(polylines: [
      Polyline(
          points: pts,
          strokeWidth: 9,
          color: palette.route.withValues(alpha: 0.28),
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round),
      Polyline(
          points: pts,
          strokeWidth: 4.5,
          color: palette.route,
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round),
    ]);
  }
}

class BridgeLayer extends ConsumerWidget {
  const BridgeLayer({super.key, required this.onTap});
  final void Function(RailBridge) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = MapCamera.of(context);
    if (camera.zoom < 8) return const SizedBox.shrink();
    final palette = MapPalette.of(context);
    final bridges = ref.watch(networkProvider).bridges;
    final bounds = camera.visibleBounds;
    final visible = [
      for (final b in bridges)
        if (bounds.contains(toLatLng(b.midpoint))) b
    ];
    final dec = _Declutter(camera, 44);
    final markable = [for (final b in visible) if (dec.take(b.midpoint)) b];
    return Stack(children: [
      PolylineLayer(polylines: [
        for (final b in visible)
          Polyline(
              points: [toLatLng(b.a), toLatLng(b.b)],
              strokeWidth: 6,
              color: palette.bridge.withValues(alpha: 0.85),
              strokeCap: StrokeCap.round),
      ]),
      if (camera.zoom >= 10)
        MarkerLayer(markers: [
          for (final b in markable)
            Marker(
              point: toLatLng(b.midpoint),
              width: 26,
              height: 26,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(b),
                child: Container(
                  decoration: BoxDecoration(
                      color: palette.bridge,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)),
                  child: const Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                ),
              ),
            ),
        ]),
    ]);
  }
}

class PlacesLayer extends ConsumerWidget {
  const PlacesLayer({super.key, required this.onTap});
  final void Function(Place) onTap;

  static const int _maxLabels = 90;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = MapCamera.of(context);
    final palette = MapPalette.of(context);
    final lang = ref.watch(languageProvider);
    final bounds = camera.visibleBounds;
    final places = ref.watch(_sortedPlacesProvider);
    final markers = <Marker>[];
    final dec = _Declutter(camera, 90, 20);
    for (final p in places) {
      if (camera.zoom < p.category.minZoom) continue;
      final ll = toLatLng(p.position);
      if (!bounds.contains(ll)) continue;
      if (!dec.take(p.position)) continue;
      final isCity = p.category == PlaceCategory.city;
      markers.add(Marker(
        point: ll,
        width: 120,
        height: 24,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => onTap(p),
          child: Center(
            child: _HaloText(
              p.displayName(lang),
              color: palette.label.withValues(alpha: isCity ? 1 : 0.75),
              halo: palette.labelHalo,
              size: isCity ? 14 : 11,
              bold: isCity,
            ),
          ),
        ),
      ));
      if (markers.length >= _maxLabels) break;
    }
    return MarkerLayer(markers: markers);
  }
}

class StationLayer extends ConsumerWidget {
  const StationLayer({super.key, required this.onTap});
  final void Function(Station) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = MapCamera.of(context);
    final palette = MapPalette.of(context);
    final net = ref.watch(networkProvider);
    final lang = ref.watch(languageProvider);
    final showLabels = ref.watch(settingsProvider.select((s) => s.showStationLabels));
    final selected = ref.watch(selectedStationProvider);
    final bounds = camera.visibleBounds;
    final zoom = camera.zoom;

    final inView = <Station>[
      for (final s in net.stations.values)
        if (bounds.contains(toLatLng(s.position))) s
    ]..sort((a, b) => net.degree(b.key).compareTo(net.degree(a.key)));
    // Declutter by screen cell: junctions win, so zoomed-out views stay readable
    // and every station appears once there is room (zoom >= ~11).
    final dec = _Declutter(camera, zoom >= 11 ? 1 : (zoom >= 9 ? 16 : 30));
    final shown = [
      for (final s in inView)
        if (s.key == selected || dec.take(s.position)) s
    ];
    final labels = showLabels && zoom >= 10;
    final labelDec = _Declutter(camera, 80, 18);

    return MarkerLayer(markers: [
      for (final s in shown)
        Marker(
          point: toLatLng(s.position),
          width: 120,
          height: 52,
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onTap(s),
            child: Stack(alignment: Alignment.center, children: [
              _StationDot(
                  junction: net.isJunction(s.key),
                  selected: s.key == selected,
                  palette: palette),
              if ((labels && labelDec.take(s.position)) || s.key == selected)
                Positioned(
                  top: 30,
                  child: _HaloText(s.displayName(lang),
                      color: palette.label,
                      halo: palette.labelHalo,
                      size: 11.5,
                      bold: true),
                ),
            ]),
          ),
        ),
    ]);
  }
}

class _StationDot extends StatelessWidget {
  const _StationDot({required this.junction, required this.selected, required this.palette});
  final bool junction, selected;
  final MapPalette palette;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 20.0 : (junction ? 15.0 : 10.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? palette.route : palette.stationFill,
        shape: BoxShape.circle,
        border: Border.all(
            color: selected ? Colors.white : palette.stationStroke,
            width: junction || selected ? 3 : 2),
        boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 3)],
      ),
    );
  }
}

class _HaloText extends StatelessWidget {
  const _HaloText(this.text,
      {required this.color, required this.halo, required this.size, this.bold = false});
  final String text;
  final Color color, halo;
  final double size;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, height: 1.2);
    return Stack(children: [
      Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = halo)),
      Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: color)),
    ]);
  }
}

/// Simulated trains. Every marker carries a DEMO badge.
class DemoTrainLayer extends ConsumerWidget {
  const DemoTrainLayer({super.key, required this.onTap, required this.badge});
  final void Function(TrainPosition) onTap;
  final String badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(trainSnapshotProvider).value;
    if (snap == null || snap.source != TrainDataSourceKind.demo) {
      return const SizedBox.shrink();
    }
    final palette = MapPalette.of(context);
    return MarkerLayer(markers: [
      for (final t in snap.trains)
        Marker(
          point: toLatLng(t.position),
          width: 84,
          height: 56,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(t),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: palette.demo,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.train, size: 17, color: Colors.white),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                    color: palette.demo, borderRadius: BorderRadius.circular(6)),
                child: Text('$badge · ${t.label}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
    ]);
  }
}

class UserLocationLayer extends ConsumerWidget {
  const UserLocationLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(userLocationProvider);
    if (p == null) return const SizedBox.shrink();
    return MarkerLayer(markers: [
      Marker(
        point: toLatLng(p),
        width: 28,
        height: 28,
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)]),
        ),
      ),
    ]);
  }
}
