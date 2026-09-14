import 'package:shared_preferences/shared_preferences.dart';

class ThresholdStorageService {
  static const String _upperKey = 'upper_threshold';
  static const String _lowerKey = 'lower_threshold';

  static Future<void> saveThresholds(double upper, double lower) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_upperKey, upper);
    await prefs.setDouble(_lowerKey, lower);
  }

  static Future<(double?, double?)> loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final upper = prefs.getDouble(_upperKey);
    final lower = prefs.getDouble(_lowerKey);
    return (upper, lower);
  }
}