class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
    this.dueDate,
    this.progress = 0,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final double progress;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    double? progress,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String? ?? '',
      dueDate: _dateFromMap(map['dueDate']),
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: _dateFromMap(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromMap(map['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _dateFromMap(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value as String);
  }
}
