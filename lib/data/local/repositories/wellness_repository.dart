import '../../../core/utils/date_utils.dart';
import '../hive_service.dart';
import '../models/daily_water_model.dart';

class WellnessRepository {
  WellnessRepository();

  static const int defaultWaterTargetMl = 2000;

  DailyWaterModel getWaterForDate(DateTime date) {
    final key = AppDateUtils.dateKey(date);
    final rawWater = HiveService.waterBox.get(key);

    if (rawWater == null) {
      final now = DateTime.now();

      return DailyWaterModel(
        dateKey: key,
        totalMl: 0,
        targetMl: defaultWaterTargetMl,
        createdAt: now,
        updatedAt: now,
      );
    }

    return DailyWaterModel.fromMap(rawWater);
  }

  Future<void> addWater({
    required DateTime date,
    required int amountMl,
  }) async {
    if (amountMl <= 0) {
      return;
    }

    final currentWater = getWaterForDate(date);

    final updatedWater = currentWater.copyWith(
      totalMl: currentWater.totalMl + amountMl,
      updatedAt: DateTime.now(),
    );

    await HiveService.waterBox.put(
      updatedWater.dateKey,
      updatedWater.toMap(),
    );
  }

  Future<void> setWaterTotal({
    required DateTime date,
    required int totalMl,
  }) async {
    final currentWater = getWaterForDate(date);

    final safeTotal = totalMl < 0 ? 0 : totalMl;

    final updatedWater = currentWater.copyWith(
      totalMl: safeTotal,
      updatedAt: DateTime.now(),
    );

    await HiveService.waterBox.put(
      updatedWater.dateKey,
      updatedWater.toMap(),
    );
  }

  Future<void> updateWaterTarget({
    required DateTime date,
    required int targetMl,
  }) async {
    final currentWater = getWaterForDate(date);

    final safeTarget = targetMl <= 0 ? defaultWaterTargetMl : targetMl;

    final updatedWater = currentWater.copyWith(
      targetMl: safeTarget,
      updatedAt: DateTime.now(),
    );

    await HiveService.waterBox.put(
      updatedWater.dateKey,
      updatedWater.toMap(),
    );
  }

  Future<void> resetWater(DateTime date) async {
    final currentWater = getWaterForDate(date);

    final updatedWater = currentWater.copyWith(
      totalMl: 0,
      updatedAt: DateTime.now(),
    );

    await HiveService.waterBox.put(
      updatedWater.dateKey,
      updatedWater.toMap(),
    );
  }

  List<DailyWaterModel> getWaterForLastDays({
    required DateTime endDate,
    int days = 30,
  }) {
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return List.generate(days, (index) {
      final date = normalizedEndDate.subtract(
        Duration(days: days - 1 - index),
      );

      return getWaterForDate(date);
    });
  }
}