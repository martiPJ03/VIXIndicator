import 'package:workmanager/workmanager.dart';
import 'vix_service.dart';
import 'threshold_storage_service.dart';
import 'notifications_service.dart';

const String vixBackgroundTaskName = "vixThresholdCheck";

@pragma('vm:entry-point')
void vixBackgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final (upper, lower) = await ThresholdStorageService.loadThresholds();
      if (upper == null && lower == null) {
        print("Thresholds not set. Skipping VIX check.");
        return await Future.value(true);
      }

      final vixService = VixService();
      final vixData = await vixService.fetchVixData();
      final currentVixValue = vixData.currentValue;

      await NotificationsService.initialize();

      await validateUpperThreshold(upper, currentVixValue);
      await validateLowerThreshold(lower, currentVixValue);

      return await Future.value(true);
    } catch (e) {
      print("Error occurred while checking VIX thresholds: $e");
      return await Future.value(false);
    }
  });

  
}

Future<void> validateUpperThreshold(double? upper, double? currentVixValue) async {
  if (currentVixValue != null && upper != null && currentVixValue > upper) {
      await NotificationsService.showNotification(
        id: 1,
        title: "VIX Alert: Above Upper Threshold",
        body: "Current VIX value is at $currentVixValue, above the upper threshold of $upper."
      );
    }
}

Future<void> validateLowerThreshold(double? lower, double? currentVixValue) async {
  if (currentVixValue != null && lower != null && currentVixValue < lower) {
      await NotificationsService.showNotification(
        id: 2,
        title: "VIX Alert: Below Lower Threshold",
        body: "Current VIX value is at $currentVixValue, below the lower threshold of $lower."
      );
    }
}