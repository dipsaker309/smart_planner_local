class RolloverHistoryModel {
  const RolloverHistoryModel({
    required this.id,
    required this.taskId,
    required this.fromDate,
    required this.toDate,
    required this.rolledOverAt,
  });

  final String id;
  final String taskId;
  final DateTime fromDate;
  final DateTime toDate;
  final DateTime rolledOverAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'rolledOverAt': rolledOverAt.toIso8601String(),
    };
  }

  factory RolloverHistoryModel.fromMap(Map<String, dynamic> map) {
    return RolloverHistoryModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      fromDate:
          DateTime.tryParse(map['fromDate'] as String? ?? '') ?? DateTime.now(),
      toDate:
          DateTime.tryParse(map['toDate'] as String? ?? '') ?? DateTime.now(),
      rolledOverAt:
          DateTime.tryParse(map['rolledOverAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
