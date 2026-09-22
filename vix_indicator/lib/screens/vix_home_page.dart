import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/vix_data.dart';
import '../models/vix_history_point.dart';
import '../models/intraday_point.dart';
import '../services/vix_service.dart';
import '../services/vix_history_service.dart';
import '../services/history_range_storage_service.dart';
import '../services/intraday_history_storage_service.dart';

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
  const VixHomePage({
    super.key, 
    required this.title,
    this.onChartInteractionChanged,
  });

  final String title;
  final ValueChanged<bool>? onChartInteractionChanged;

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
    final rangeToApply = savedRange ?? _selectedRange;

    if (mounted) {
      setState(() {
        _selectedRange = rangeToApply;
      });
    }

    if (rangeToApply == ChartRange.day) {
      await _applyRange(ChartRange.day);
      unawaited(_loadHistory(showLoadingIndicator: false));
    } else {
      await _loadHistory();
    }
  }

  Future<void> _loadHistory({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() => _isLoadingHistory = true);
    }
    try {
      final history = await _vixHistoryService.fetchVixHistory();
      _fullVixHistory = history;
      _historyError = null;
      if (showLoadingIndicator) {
        await _applyRange(_selectedRange);
      }
    } catch (e) {
      _historyError = e.toString();
      if (showLoadingIndicator) {
        setState(() {});
      }
    } finally {
      if (showLoadingIndicator) {
        setState(() => _isLoadingHistory = false);
      }
    }
}

  Future<void> _applyRange(ChartRange range) async{
    if (range == ChartRange.day) {
      setState(() {
        _selectedRange = range;
        _isLoadingHistory = true;
        _historyError = null;
      });
      
      try {
        final points = await IntradayHistoryStorageService.loadPoints();
        setState((){
          _chartPoints = points.map(_toHistoryPoint).toList();
        });
      } catch (e) {
        setState(() => _historyError = e.toString());
      } finally {
        setState(() => _isLoadingHistory = false);
      }

      await HistoryRangeStorageService.saveHistoryRange(range);
      return;
    }

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

  VixHistoryPoint _toHistoryPoint(IntradayPoint point) {
    return VixHistoryPoint(
      date: point.timestamp,
      open: point.value,
      high: point.value,
      low: point.value,
      close: point.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: _error != null
                    ? Text('Error: $_error')
                    : _vixData == null
                        ? const CircularProgressIndicator()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('VIX:'),
                              Text(
                                _vixData!.currentValue.toStringAsFixed(2),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Listener(
                  onPointerDown: (_) =>
                      widget.onChartInteractionChanged?.call(true),
                  onPointerUp: (_) =>
                      widget.onChartInteractionChanged?.call(false),
                  onPointerCancel: (_) =>
                      widget.onChartInteractionChanged?.call(false),
                  child: _buildChart(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRangeSelector(),
            ),
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
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color.fromARGB(179, 255, 255, 255),
          ),
        ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ChartRange.values.map((range) {
        final isEnabled = range == ChartRange.day || range.serviceRange != null;
        final isSelected = range == _selectedRange;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: OutlinedButton(
              onPressed: isEnabled ? () => _applyRange(range) : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                backgroundColor: isSelected ? Colors.deepPurple : null,
                foregroundColor: isSelected ? Colors.white : null,
              ),
              child: Text(
                range.label, 
                style: const TextStyle(fontSize: 16)
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}