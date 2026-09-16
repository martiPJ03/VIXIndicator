import 'package:shared_preferences/shared_preferences.dart';

enum ChartRange { day, week, month, year, fiveYear }

extension ChartRangeLabel on ChartRange {
  String get label => switch (this) {
    ChartRange.day => 'Day',
    ChartRange.week => 'Week',
    ChartRange.month => 'Month',
    ChartRange.year => 'Year',
    ChartRange.fiveYear => '5Y',
  };
}

class HistoryRangeStorageService {
  static const String _historyRangeKey = 'history_range';

  static Future<void> saveHistoryRange(ChartRange range) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyRangeKey, range.label);
  }

  static Future<ChartRange?> loadHistoryRange() async {
    final prefs = await SharedPreferences.getInstance();
    final label = prefs.getString(_historyRangeKey);
    
    if (label == null) return null;
    
    try {
      return ChartRange.values.firstWhere((e) => e.label == label);
    } catch (_) {
      return null;
    }
  }
}