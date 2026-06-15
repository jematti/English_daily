import 'package:english_drops_daily/core/theme/app_theme.dart';
import 'package:english_drops_daily/features/dashboard/screens/dashboard_screen.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await const AppSettingsStorageService().loadSettings();

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notificationService.openPendingNotificationRoute();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettingsModel>(
      valueListenable: AppSettingsStorageService.settingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'English Drops Daily',
          debugShowCheckedModeBanner: false,
          navigatorKey: NotificationService.navigatorKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: switch (settings.themePreference) {
            AppThemePreference.light => ThemeMode.light,
            AppThemePreference.dark => ThemeMode.dark,
            AppThemePreference.system => ThemeMode.system,
          },
          home: const DashboardScreen(),
        );
      },
    );
  }
}
