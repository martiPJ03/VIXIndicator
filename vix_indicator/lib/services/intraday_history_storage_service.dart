import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/intraday_point.dart';

class IntradayHistoryStorageService {
  static const String _key = 'intraday_vix_points';
  static const int _maxPoints = 24;
  static const Duration _minGapBetweenPoints = Duration(minutes: 55);


  static Future<List<IntradayPoint>> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return [];
    }

    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => IntradayPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<bool> addPointIfDue(double value, {DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final points = await loadPoints();

    if (points.isNotEmpty) {
      final lastPoint = points.last;
      if (currentTime.difference(lastPoint.timestamp) < _minGapBetweenPoints) {
        return false; // Not enough time has passed since the last point
      }
    }

    points.add(IntradayPoint(timestamp: currentTime, value: value));
    final trimmed = points.length > _maxPoints 
      ? points.sublist(points.length - _maxPoints) 
      : points;

    await _savePoints(trimmed);
    return true;
  }

  static Future<void> _savePoints(List<IntradayPoint> points) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(points.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}