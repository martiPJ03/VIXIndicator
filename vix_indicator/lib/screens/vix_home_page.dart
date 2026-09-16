import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/vix_data.dart';
import '../models/vix_history_point.dart';
import '../services/vix_service.dart';
import '../services/vix_history_service.dart';
import '../services/notifications_service.dart';
import '../services/history_range_storage_service.dart';

extension on ChartRange {
  VixTimeRange? get serviceRange => switch (this) {
    ChartRange.day => null,
    ChartRange.week => VixTimeRange.week,
    ChartRange.month => VixTimeRange.month,
    ChartRange.year => VixTimeRange.year,
    ChartRange.fiveYear => VixTimeRange.fiveYear,
  };
}


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

  final VixHistoryService _vixHistoryService = VixHistoryService();
  List<VixHistoryPoint> _fullVixHistory = [];
  List<VixHistoryPoint> _chartPoints = [];
  ChartRange _selectedRange = ChartRange.week;
  bool _isLoadingHistory = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _fetchVix();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) => _fetchVix());
    _initializeHistory();
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

  Future<void> _initializeHistory() async {
  final savedRange = await HistoryRangeStorageService.loadHistoryRange();
  
  if (savedRange != null && mounted) {
    setState(() {
      _selectedRange = savedRange;
    });
  }

  await _loadHistory();
}

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _vixHistoryService.fetchVixHistory();
      _fullVixHistory = history;
      _historyError = null;
      _applyRange(_selectedRange);
    } catch (e) {
      setState(() => _historyError = e.toString());
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  void _applyRange(ChartRange range) {
    final serviceRange = range.serviceRange;
    if (serviceRange == null) {
      return;
    }

    setState((){
      _selectedRange = range;
      _chartPoints = _vixHistoryService.filterByTimeRange(_fullVixHistory, range.serviceRange!);
    });

    HistoryRangeStorageService.saveHistoryRange(range);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
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
                              ElevatedButton(
                                child: const Icon(Icons.notifications),
                                onPressed: () {
                                  NotificationsService.showNotification(
                                    title: 'VIX Update',
                                    body: 'Current VIX: ${_vixData?.currentValue.toStringAsFixed(2) ?? 'N/A'}',
                                  );
                                },
                              ),
                            ],
                          ),
              ),
            ),
            SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildChart(),
              ),
            ),
            const SizedBox(height: 12),
            _buildRangeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoadingHistory && _chartPoints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null && _chartPoints.isEmpty) {
      return Center(child: Text('Could not load history: $_historyError'));
    }
    if (_chartPoints.isEmpty) {
      return const Center(child: Text('No history data yet'));
    }
 
    final spots = <FlSpot>[
      for (var i = 0; i < _chartPoints.length; i++)
        FlSpot(i.toDouble(), _chartPoints[i].close),
    ];
 
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepPurple.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ChartRange.values.map((range) {
        final isEnabled = range.serviceRange != null;
        final isSelected = range == _selectedRange;
 
        return OutlinedButton(
          onPressed: isEnabled ? () => _applyRange(range) : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.deepPurple : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          child: Text(range.label),
        );
      }).toList(),
    );
  }
}