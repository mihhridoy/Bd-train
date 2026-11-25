import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import 'home_shell.dart';

/// Shows loading / error while the bundled datasets parse, then the app.
class HomeGate extends ConsumerWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(railDataProvider);
    return data.when(
      data: (_) => const HomeShell(),
      loading: () => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('assets/icon/app_icon.png', width: 96, height: 96),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l.loading),
          ]),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(l.loadError, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('$e', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(railDataProvider),
                child: Text(l.retry),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
