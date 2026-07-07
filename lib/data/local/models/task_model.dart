class TaskModel {
  const TaskModel({
    required this.id,
    required this.planDate,
    required this.title,
    required this.description,
    required this.progress,
    required this.priority,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.rolloverSourceTaskId,
  });

  final String id;
  final String planDate; // yyyy-MM-dd
  final String title;
  final String description;
  final int progress; // 0 to 100
  final String priority; // low, medium, high
  final String? rolloverSourceTaskId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => progress >= 100;
  bool get isPending => progress <= 0;
  bool get isPartiallyDone => progress > 0 && progress < 100;

  String get statusLabel {
    if (isDone) return 'Done';
    if (isPending) return 'Pending';
    return 'Partial';
  }

  String get priorityLabel {
    switch (priority) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      case 'medium':
      default:
        return 'Medium';
    }
  }

  int get priorityRank {
    switch (priority) {
      case 'high':
        return 0;
      case 'medium':
        return 1;
      case 'low':
        return 2;
      default:
        return 1;
    }
  }

  TaskModel copyWith({
    String? id,
    String? planDate,
    String? title,
    String? description,
    int? progress,
    String? priority,
    String? rolloverSourceTaskId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      planDate: planDate ?? this.planDate,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      rolloverSourceTaskId: rolloverSourceTaskId ?? this.rolloverSourceTaskId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planDate': planDate,
      'title': title,
      'description': description,
      'progress': progress,
      'priority': priority,
      'rolloverSourceTaskId': rolloverSourceTaskId,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      planDate: map['planDate'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      priority: map['priority'] as String? ?? 'medium',
      rolloverSourceTaskId: map['rolloverSourceTaskId'] as String?,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}