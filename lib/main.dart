import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/decision/screens/home_screen.dart';
import 'features/decision/screens/create_decision_screen.dart';
import 'features/decision/screens/clarity_result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ClarityApp()));
}

class ClarityApp extends ConsumerWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Clarity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Supports both Light & Dark modes natively
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateDecisionScreen(),
    ),
    GoRoute(
      path: '/decision/:id',
      builder: (context, state) =>
          ClarityResultScreen(decisionId: state.pathParameters['id']!),
    ),
  ],
);
