import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/train.dart';
import '../../shared/config.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';

/// Bottom sheet for a (demo) train. Always shows the DEMO badge.
Future<void> showTrainSheet(BuildContext context, TrainPosition train) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => TrainSheet(trainId: train.id),
    );

class TrainSheet extends ConsumerWidget {
  const TrainSheet({super.key, required this.trainId});
  final String trainId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final fmt = Fmt(lang);
    final net = ref.watch(networkProvider);
    final palette = MapPalette.of(context);
    final snap = ref.watch(trainSnapshotProvider).value;
    final train = snap?.trains.where((t) => t.id == trainId).firstOrNull;
    if (train == null) return const SizedBox(height: 120);
    String name(String? k) => k == null ? '' : (net.station(k)?.displayName(lang) ?? k);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Chip(
              backgroundColor: palette.demo,
              side: BorderSide.none,
              label: Text(l.demoBadge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Text(train.label, style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 8),
          Text('${name(train.originKey)} → ${name(train.destinationKey)}'),
          Text(l.trainProgress(fmt.digits(((train.progress ?? 0) * 100).round()))),
          Text(l.trainSpeed(fmt.digits(train.speedKmh.round()))),
          const SizedBox(height: 8),
          Text(l.demoBanner, style: TextStyle(color: palette.demo, fontWeight: FontWeight.w600)),
          if (FeatureFlags.audio && ref.watch(settingsProvider).soundEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => ref.read(audioServiceProvider).playHorn(),
                icon: const Icon(Icons.volume_up),
                label: Text(l.hornPlay),
              ),
            ),
        ]),
      ),
    );
  }
}
