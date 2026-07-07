import '../hive_service.dart';

class SettingsRepository {
  SettingsRepository();

  static const String _dailyCalorieTargetKey = 'dailyCalorieTarget';

  double getDailyCalorieTarget() {
    final rawSetting = HiveService.settingsBox.get(_dailyCalorieTargetKey);

    if (rawSetting == null) {
      return 2000;
    }

    final value = rawSetting['value'];

    if (value is num) {
      return value.toDouble();
    }

    return 2000;
  }

  Future<void> setDailyCalorieTarget(double target) async {
    await HiveService.settingsBox.put(
      _dailyCalorieTargetKey,
      {
        'value': target,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}