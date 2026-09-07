import 'package:flutter/material.dart';
import 'screens/vix_home_page.dart';
import 'services/notifications_service.dart';

void main() {
	WidgetsFlutterBinding.ensureInitialized();

	await NotificationsService.initialize();

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
      home: const VixHomePage(title: 'Vix Indicator'),
    );
  }
}