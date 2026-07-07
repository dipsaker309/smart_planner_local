import 'package:hive_ce_flutter/hive_flutter.dart';

import 'boxes.dart';

class HiveService {
  const HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox<Map>(Boxes.tasks),
      Hive.openBox<Map>(Boxes.foodLogs),
      Hive.openBox<Map>(Boxes.foodItems),
      Hive.openBox<Map>(Boxes.rolloverHistory),
    ]);
  }

  static Box<Map> get tasksBox => Hive.box<Map>(Boxes.tasks);
  static Box<Map> get foodLogsBox => Hive.box<Map>(Boxes.foodLogs);
  static Box<Map> get foodItemsBox => Hive.box<Map>(Boxes.foodItems);
  static Box<Map> get rolloverHistoryBox =>
      Hive.box<Map>(Boxes.rolloverHistory);

  static Future<void> close() {
    return Hive.close();
  }
}
