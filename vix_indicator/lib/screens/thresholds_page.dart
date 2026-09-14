import 'package:flutter/material.dart';

class ThresholdsPage extends StatefulWidget {
  const ThresholdsPage({super.key});

  @override
  State<ThresholdsPage> createState() => _ThresholdsPageState();

}

class _ThresholdsPageState extends State<ThresholdsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Thresholds'),
      ),
      body: const Center(
        child: Text('Thresholds Page'),
      ),
    );
  }
}
