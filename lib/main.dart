import 'package:english_drops_daily/features/dashboard/screens/dashboard_screen.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notificationService.openPendingNotificationRoute();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Drops Daily',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
