import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vix_data.dart';
import '../services/vix_service.dart';

class VixHomePage extends StatefulWidget {
  const VixHomePage({super.key, required this.title});

  final String title;

  @override
  State<VixHomePage> createState() => _VixHomePageState();
}

class _VixHomePageState extends State<VixHomePage> {
  final VixService _vixService = VixService();
  VixData? _vixData;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchVix();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) => _fetchVix());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchVix() async {
    try {
      final data = await _vixService.fetchVixData();
      setState(() {
        _vixData = data;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: _error != null
            ? Text('Error: $_error')
            : _vixData == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('VIX:'),
                      Text(
                        _vixData!.currentValue.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchVix,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}