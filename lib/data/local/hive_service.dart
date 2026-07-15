import 'package:hive_ce_flutter/hive_flutter.dart';

import 'boxes.dart';

class HiveService {
  const HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox<Map>(HiveBoxes.tasks),
      Hive.openBox<Map>(HiveBoxes.foodLogs),
      Hive.openBox<Map>(HiveBoxes.foodDictionary),
      Hive.openBox<Map>(HiveBoxes.rolloverHistory),
      Hive.openBox<Map>(HiveBoxes.settings),
      Hive.openBox<Map>(HiveBoxes.water),
    ]);
  }

  static Box<Map> get tasksBox => Hive.box<Map>(HiveBoxes.tasks);

  static Box<Map> get foodLogsBox => Hive.box<Map>(HiveBoxes.foodLogs);

  static Box<Map> get foodDictionaryBox =>
      Hive.box<Map>(HiveBoxes.foodDictionary);

  static Box<Map> get rolloverHistoryBox =>
      Hive.box<Map>(HiveBoxes.rolloverHistory);

  static Box<Map> get settingsBox => Hive.box<Map>(HiveBoxes.settings);

  static Box<Map> get waterBox => Hive.box<Map>(HiveBoxes.water);
}