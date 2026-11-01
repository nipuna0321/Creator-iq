import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/add_data/add_data_screen.dart';
import '../../screens/ai_studio/ai_studio_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/connect/connect_accounts_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/insights/insights_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/questionnaire/questionnaire_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../widgets/main_shell.dart';

/// Route paths used across the app.
class Routes {
  Routes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const connect = '/connect';
  static const home = '/home';
  static const analytics = '/analytics';
  static const addData = '/add-data';
  static const aiStudio = '/ai-studio';
  static const profile = '/profile';
  static const chat = '/chat';
  static const insights = '/insights';
  static const questionnaire = '/questionnaire';
}

/// Fade + slight upward slide used for full-screen routes.
CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Cross-fade between bottom-nav tabs.
NoTransitionPage<void> _tab(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(path: Routes.splash, pageBuilder: (c, s) => _page(s, const SplashScreen())),
    GoRoute(path: Routes.onboarding, pageBuilder: (c, s) => _page(s, const OnboardingScreen())),
    GoRoute(path: Routes.login, pageBuilder: (c, s) => _page(s, const LoginScreen())),
    GoRoute(path: Routes.connect, pageBuilder: (c, s) => _page(s, const ConnectAccountsScreen())),
    GoRoute(path: Routes.chat, pageBuilder: (c, s) => _page(s, const ChatScreen())),
    GoRoute(path: Routes.insights, pageBuilder: (c, s) => _page(s, const InsightsScreen())),
    GoRoute(path: Routes.questionnaire, pageBuilder: (c, s) => _page(s, const QuestionnaireScreen())),

    // Bottom navigation shell with 5 independent tab stacks.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.home, pageBuilder: (c, s) => _tab(s, const HomeScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.analytics, pageBuilder: (c, s) => _tab(s, const AnalyticsScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.addData, pageBuilder: (c, s) => _tab(s, const AddDataScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.aiStudio, pageBuilder: (c, s) => _tab(s, const AiStudioScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.profile, pageBuilder: (c, s) => _tab(s, const ProfileScreen())),
        ]),
      ],
    ),
  ],
);
