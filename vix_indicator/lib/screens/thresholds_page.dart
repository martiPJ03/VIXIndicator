import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vix_indicator/services/threshold_storage_service.dart';

class ThresholdsPage extends StatefulWidget {
  const ThresholdsPage({super.key});

  @override
  State<ThresholdsPage> createState() => _ThresholdsPageState();

}

class _ThresholdsPageState extends State<ThresholdsPage> {
  final _upperController = TextEditingController();
  final _lowerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved thresholds from storage
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    final (upper, lower) = await ThresholdStorageService.loadThresholds();
    if (upper != null) {
      _upperController.text = upper.toString();
    }
    if (lower != null) {
      _lowerController.text = lower.toString();
    }
  }

  Future<void> _saveThresholds() async {
    final upper = double.tryParse(_upperController.text);
    final lower = double.tryParse(_lowerController.text);

    if (upper == null || lower == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid values for both thresholds.')),
      );
      return;
    }

    await ThresholdStorageService.saveThresholds(upper, lower);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thresholds saved successfully.')),
      );
    }
  }

  @override
  void dispose() {
    _upperController.dispose();
    _lowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Thresholds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _upperController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              decoration: const InputDecoration(
                labelText: 'Upper Threshold',
                border: OutlineInputBorder(),
                suffixText: 'VIX',
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lowerController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              decoration: const InputDecoration(
                labelText: 'Lower Threshold',
                border: OutlineInputBorder(),
                suffixText: 'VIX',
              )
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveThresholds,
              child: const Text('Save'),
            ),
          ]
        )
      ),
    );
  }
}
