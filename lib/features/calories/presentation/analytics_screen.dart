import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('30-Day Analytics'),
      ),
      body: const Center(
        child: Text(
          'Analytics chart will be built here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}