import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'features/home/presentation/home_screen.dart';

class SmartPlannerApp extends StatelessWidget {
  const SmartPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const HomeScreen(),
    );
  }
}