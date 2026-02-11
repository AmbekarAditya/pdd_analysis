import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/app_theme.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'features/train_record/ui/train_records_screen.dart';
import 'features/train_record/ui/add_record_screen.dart';
import 'features/train_record/ui/analysis_screen.dart';
import 'shared/widgets/main_layout.dart';
import 'shared/providers/layout_providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PDDApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisScreen(),
        ),
        GoRoute(
          path: '/train-record/new',
          builder: (context, state) => const AddRecordScreen(),
        ),
        GoRoute(
          path: '/train-records',
          builder: (context, state) => const TrainRecordsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const PlaceholderScreen(title: 'Admin Panel'),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PlaceholderScreen(title: 'Login'),
    ),
  ],
);

class PDDApp extends StatelessWidget {
  const PDDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PDD Analysis',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlaceholderScreen extends ConsumerWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).update(title: title);
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Coming Soon: $title', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}
