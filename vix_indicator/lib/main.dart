import 'package:flutter/material.dart';
import 'services/notifications_service.dart';
import 'main_page.dart';
import 'package:workmanager/workmanager.dart';
import 'services/background_service.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    vixBackgroundTaskDispatcher,
  );

  Workmanager().registerPeriodicTask(
    "1",
    vixBackgroundTaskName,
    frequency: const Duration(minutes: 15),
  );

	await NotificationsService.initialize();
	await NotificationsService.requestPermission();
	
  	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vix Indicator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}