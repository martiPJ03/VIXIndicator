import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vix_history_point.dart';

enum VixTimeRange { week, month, year, fiveYear }

class VixHistoryService {
  static const String _historyUrl =
      'https://cdn.cboe.com/api/global/us_indices/daily_prices/VIX_History.csv';
  
  static const String _cacheKey = 'vix_history_cache';
  static const String _cacheTimestampKey = 'vix_history_cache_timestamp';

  static const Duration _cacheDuration = Duration(hours: 12);

  Future<List<VixHistoryPoint>> fetchVixHistory({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = _readFreshCache(prefs);
      if (cached != null) {
        return _parseCsv(cached);
      }
    }

    try {
      final response = await http.get(Uri.parse(_historyUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load VIX history (${response.statusCode})');
      }

      await prefs.setString(_cacheKey, response.body);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      return _parseCsv(response.body);
    }  catch (e) {
      // If the network call fails, fall back to whatever we have cached
      // (even if stale) rather than leaving the caller with nothing.
      final stale = prefs.getString(_cacheKey);
      if (stale != null) {
        return _parseCsv(stale);
      }
      rethrow;
    }
  }

  String? _readFreshCache(SharedPreferences prefs) {
    final cached = prefs.getString(_cacheKey);
    final cachedAtMillis = prefs.getInt(_cacheTimestampKey);
    if (cached == null || cachedAtMillis == null) {
      return null;
    }

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) {
      return null;
    }

    return cached;
  }

  List<VixHistoryPoint> _parseCsv(String csv) {
    final lines = const LineSplitter().convert(csv);
    return lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty)
        .map(VixHistoryPoint.fromCsvRow)
        .toList();
  }

  List<VixHistoryPoint> filterByTimeRange(List<VixHistoryPoint> history, VixTimeRange range) {
    if (history.isEmpty) return [];

    final latestDate = history.last.date;
    final cutoff = switch (range) {
      VixTimeRange.week => latestDate.subtract(const Duration(days: 7)),
      VixTimeRange.month => latestDate.subtract(const Duration(days: 30)),
      VixTimeRange.year => latestDate.subtract(const Duration(days: 365)),
      VixTimeRange.fiveYear => latestDate.subtract(const Duration(days: 365 * 5)),
    };

    return history.where((point) => point.date.isAfter(cutoff)).toList();
  }
}