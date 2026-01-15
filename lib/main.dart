import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/medicine_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    MedicineReminderApp(
      storageService: storageService,
      notificationService: notificationService,
    ),
  );
}

class MedicineReminderApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const MedicineReminderApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<MedicineProvider>(
          create: (_) => MedicineProvider(
            storageService: storageService,
            notificationService: notificationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Medicine Reminder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
