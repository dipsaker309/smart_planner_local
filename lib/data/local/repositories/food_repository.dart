import 'package:hive_ce/hive.dart';

import '../hive_service.dart';
import '../models/food_log_model.dart';

class FoodRepository {
  FoodRepository({Box<Map>? box}) : _box = box ?? HiveService.foodLogsBox;

  final Box<Map> _box;

  List<FoodLogModel> getAllLogs() {
    final logs = _box.values
        .map((value) => FoodLogModel.fromMap(Map<String, dynamic>.from(value)))
        .toList();

    logs.sort((first, second) => second.date.compareTo(first.date));
    return logs;
  }

  Future<void> saveLog(FoodLogModel log) {
    return _box.put(log.id, log.toMap());
  }

  Future<void> deleteLog(String logId) {
    return _box.delete(logId);
  }
}
