import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/capture_screens.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/patient_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Uri.base.queryParameters['start'] ?? '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const HistoryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())]),
        ],
      ),
      GoRoute(path: '/new/guide', builder: (_, _) => const CaptureGuideScreen()),
      GoRoute(path: '/new/camera', builder: (_, _) => const CameraScreen()),
      GoRoute(path: '/new/check', builder: (_, _) => const QualityCheckScreen()),
      GoRoute(path: '/new/patient', builder: (_, _) => const PatientScreen()),
      GoRoute(path: '/new/processing', builder: (_, _) => const ProcessingScreen()),
      GoRoute(
        path: '/case/:id',
        builder: (_, s) => ResultScreen(
          caseId: s.pathParameters['id']!,
          fresh: s.uri.queryParameters['fresh'] == '1',
        ),
      ),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
    ],
  );
});

class EcgApp extends ConsumerWidget {
  const EcgApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider).lang;
    return MaterialApp.router(
      title: 'ECG-AI KG',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.history), label: l.history),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l.settings),
        ],
      ),
    );
  }
}
