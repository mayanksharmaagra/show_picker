import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'HomeScreen.dart';
import 'SavedPicksScreen.dart';
import 'SplashScreen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedPicksScreen(),
    ),
  ],
);