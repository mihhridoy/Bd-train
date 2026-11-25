import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'features/home/home_gate.dart';
import 'services/settings_store.dart';
import 'shared/l10n/generated/app_localizations.dart';
import 'shared/providers.dart';
import 'shared/theme/app_theme.dart';

class BdTrainApp extends ConsumerWidget {
  const BdTrainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      theme: AppTheme.build(Brightness.light, language: settings.language),
      darkTheme: AppTheme.build(Brightness.dark, language: settings.language),
      home: const HomeGate(),
    );
  }
}
