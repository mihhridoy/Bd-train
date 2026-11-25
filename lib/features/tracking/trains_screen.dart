import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/repositories/mock_train_repository.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/entities/train.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import 'train_sheet.dart';

class TrainsScreen extends StatelessWidget {
  const TrainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.trainsTitle),
          bottom: TabBar(tabs: [Tab(text: l.tabTracking), Tab(text: l.tabTimetable)]),
        ),
        body: const TabBarView(children: [_TrackingTab(), _TimetableTab()]),
      ),
    );
  }
}

// ------------------------------------------------------------------ tracking

class _TrackingTab extends ConsumerStatefulWidget {
  const _TrackingTab();
  @override
  ConsumerState<_TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends ConsumerState<_TrackingTab> {
  bool _paused = false;

  void _setDemo(bool on) {
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(demoEnabled: on));
    _paused = false;
    final audio = ref.read(audioServiceProvider);
    if (!on) audio.stopRailLoop();
  }

  void _togglePause() {
    final repo = ref.read(trainRepositoryProvider);
    if (repo is MockTrainRepository) {
      setState(() => _paused = !_paused);
      repo.setPaused(_paused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final demo = ref.watch(demoEnabledProvider);

    if (!demo) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 24),
        Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(l.trackingNotConfiguredTitle,
            style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(l.trackingNotConfiguredBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.science),
            label: Text(l.startDemo),
            onPressed: () => _setDemo(true),
          ),
        ),
      ]);
    }

    final palette = MapPalette.of(context);
    final fmt = Fmt(ref.watch(languageProvider));
    final lang = ref.watch(languageProvider);
    final net = ref.watch(networkProvider);
    final snapAsync = ref.watch(trainSnapshotProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final snap = snapAsync.value;
    final fresh = ref.watch(stalenessPolicyProvider).evaluate(snap?.fetchedAt, now);
    String name(String? k) => k == null ? '' : (net.station(k)?.displayName(lang) ?? k);

    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: palette.demo, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.science, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l.demoBanner,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      Text(l.demoSpeed(fmt.digits(MockTrainRepository.defaultTimeScale.round())),
          style: theme.textTheme.bodySmall),
      const SizedBox(height: 8),
      if (snap != null)
        Row(children: [
          Icon(fresh == Freshness.stale ? Icons.warning_amber : Icons.check_circle_outline,
              size: 18, color: fresh == Freshness.stale ? theme.colorScheme.error : null),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              fresh == Freshness.stale
                  ? l.staleBanner(fmt.digits(now.difference(snap.fetchedAt).inSeconds))
                  : l.updatedAt(fmt.clock(snap.fetchedAt)),
              style: TextStyle(color: fresh == Freshness.stale ? theme.colorScheme.error : null),
            ),
          ),
        ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        OutlinedButton.icon(
          icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
          label: Text(_paused ? l.resumeFeed : l.pauseFeed),
          onPressed: _togglePause,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.stop),
          label: Text(l.stopDemo),
          onPressed: () => _setDemo(false),
        ),
      ]),
      const SizedBox(height: 12),
      if (snapAsync.hasError)
        Padding(padding: const EdgeInsets.all(16), child: Text(l.trainsError))
      else if (snap == null)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 8), Text(l.trainsLoading)]),
        )
      else if (snap.isEmpty)
        Padding(padding: const EdgeInsets.all(16), child: Text(l.trainsEmpty))
      else
        for (final t in snap.trains)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: palette.demo,
                child: const Icon(Icons.train, color: Colors.white),
              ),
              title: Row(children: [
                Text(t.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: palette.demo, borderRadius: BorderRadius.circular(6)),
                  child: Text(l.demoBadge,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ]),
              subtitle: Text(
                  '${name(t.originKey)} → ${name(t.destinationKey)}\n${l.trainProgress(fmt.digits(((t.progress ?? 0) * 100).round()))} · ${l.trainSpeed(fmt.digits(t.speedKmh.round()))}'),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: l.showOnMap,
                icon: const Icon(Icons.map),
                onPressed: () {
                  ref.read(homeTabProvider.notifier).go(HomeTab.map);
                  ref.read(mapCommandProvider.notifier).send(MapCommand.focus(t.position, zoom: 10));
                },
              ),
              onTap: () => showTrainSheet(context, t),
            ),
          ),
    ]);
  }
}

// ----------------------------------------------------------------- timetable

class _TimetableTab extends ConsumerWidget {
  const _TimetableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = Fmt(ref.watch(languageProvider));
    final tt = ref.watch(timetableProvider);
    return tt.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.loadError)),
      data: (entries) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l.timetablePartialNotice,
                  style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        for (final e in entries) _TimetableCard(entry: e, fmt: fmt),
      ]),
    );
  }
}

class _TimetableCard extends ConsumerWidget {
  const _TimetableCard({required this.entry, required this.fmt});
  final TimetableEntry entry;
  final Fmt fmt;

  String _svc(AppLocalizations l) => switch (entry.serviceType) {
        'intercity' => l.svcIntercity,
        'mail_express' => l.svcMail,
        'international' => l.svcInternational,
        _ => l.svcOther,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final net = ref.watch(networkProvider);
    String place(String name, String? key) =>
        key != null ? (net.station(key)?.displayName(lang) ?? name) : name;
    final off = entry.weeklyOffDay;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('${fmt.digits(entry.trainNumber)} · ${(lang == 'bn' && entry.nameBn != null) ? entry.nameBn! : entry.nameEn}',
                  style: theme.textTheme.titleMedium),
            ),
            Chip(label: Text(_svc(l)), visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text(place(entry.originName, entry.originKey))),
            const Icon(Icons.arrow_forward, size: 16),
            Expanded(
                child: Text(place(entry.destinationName, entry.destinationKey),
                    textAlign: TextAlign.end)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(fmt.hhmm(entry.departureTime), style: theme.textTheme.titleLarge),
            const Spacer(),
            if (entry.arrivesNextDay)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(l.nextDayArrival, style: theme.textTheme.bodySmall),
              ),
            Text(fmt.hhmm(entry.arrivalTime), style: theme.textTheme.titleLarge),
          ]),
          const SizedBox(height: 4),
          Text(
            off == null
                ? ''
                : off.toLowerCase() == 'no'
                    ? l.noOffDay
                    : l.offDay(fmt.weekdays(off)),
            style: theme.textTheme.bodySmall,
          ),
          Text(l.verificationPartial, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary)),
          const SizedBox(height: 6),
          if (entry.canShowOnMap)
            TextButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: Text(l.viewOnMap),
              onPressed: () {
                final route = ref.read(routeFinderProvider).find(entry.originKey!, entry.destinationKey!);
                if (route == null) return;
                ref.read(activeRouteProvider.notifier).set(route);
                ref.read(homeTabProvider.notifier).go(HomeTab.map);
                ref.read(mapCommandProvider.notifier).send(MapCommand.fitRoute(route));
              },
            )
          else
            Text(l.notOnMap, style: theme.textTheme.bodySmall),
        ]),
      ),
    );
  }
}
