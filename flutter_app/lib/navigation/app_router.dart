import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/create_batch_screen.dart';
import '../screens/heap_analysis_screen.dart';
import '../screens/batch_details_screen.dart';
import '../screens/inspection_history_screen.dart';
import '../screens/certificate_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String createBatch = '/create-batch';
  static const String heapAnalysis = '/heap-analysis';
  static const String batchDetails = '/batch-details';
  static const String inspectionHistory = '/inspection-history';
  static const String certificate = '/certificate';
  static const String verification = '/verification';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.createBatch,
      builder: (context, state) => const CreateBatchScreen(),
    ),
    GoRoute(
      path: AppRoutes.heapAnalysis,
      builder: (context, state) {
        final batchId = state.uri.queryParameters['batchId'];
        return HeapAnalysisScreen(batchId: batchId);
      },
    ),
    GoRoute(
      path: AppRoutes.batchDetails,
      builder: (context, state) {
        final batchId = state.uri.queryParameters['batchId'] ?? '';
        return BatchDetailsScreen(batchId: batchId);
      },
    ),
    GoRoute(
      path: AppRoutes.inspectionHistory,
      builder: (context, state) => const InspectionHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.certificate,
      builder: (context, state) {
        final certNumber = state.uri.queryParameters['certNumber'] ?? '';
        return CertificateScreen(certificateNumber: certNumber);
      },
    ),
    GoRoute(
      path: AppRoutes.verification,
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
