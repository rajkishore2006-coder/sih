import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'navigation/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/batch_provider.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/localization_service.dart';
import 'services/offline_sync_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline Hive storage and preferences
  final storageService = StorageService();
  await storageService.init();

  final connectivityService = ConnectivityService();
  final apiService = ApiService(storageService);
  final offlineSyncService = OfflineSyncService(
    storageService,
    apiService,
    connectivityService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ConnectivityService>.value(value: connectivityService),
        Provider<ApiService>.value(value: apiService),
        Provider<OfflineSyncService>.value(value: offlineSyncService),
        ChangeNotifierProvider<LocalizationService>(
          create: (_) => LocalizationService(storageService),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(storageService),
        ),
        ChangeNotifierProvider<OnionBatchProvider>(
          create: (_) => OnionBatchProvider(
            storageService,
            apiService,
            offlineSyncService,
            connectivityService,
          ),
        ),
      ],
      child: const OnionSureApp(),
    ),
  );
}

class OnionSureApp extends StatelessWidget {
  const OnionSureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = context.watch<LocalizationService>();

    return MaterialApp.router(
      title: 'OnionSure',
      debugShowCheckedModeBanner: false,
      theme: OnionSureTheme.lightTheme,
      routerConfig: appRouter,
      locale: localizationService.currentLocale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
