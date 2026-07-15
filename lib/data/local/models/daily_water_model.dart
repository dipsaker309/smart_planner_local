class DailyWaterModel {
  const DailyWaterModel({
    required this.dateKey,
    required this.totalMl,
    required this.targetMl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String dateKey; // yyyy-MM-dd
  final int totalMl;
  final int targetMl;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get progress {
    if (targetMl <= 0) {
      return 0;
    }

    return totalMl / targetMl;
  }

  int get progressPercent {
    return (progress * 100).round();
  }

  String get feedbackTitle {
    if (totalMl <= 0) {
      return 'No water logged yet';
    }

    if (progress < 0.4) {
      return 'Low intake so far';
    }

    if (progress < 0.8) {
      return 'Keep sipping';
    }

    if (progress <= 1.2) {
      return 'On track';
    }

    return 'Above target';
  }

  String get feedbackMessage {
    if (totalMl <= 0) {
      return 'Start by logging your first glass of water for this date.';
    }

    if (progress < 0.4) {
      return 'Your intake is still low compared with your daily target.';
    }

    if (progress < 0.8) {
      return 'You are making progress. Keep drinking water gradually.';
    }

    if (progress <= 1.2) {
      return 'You are close to or within your daily water target.';
    }

    return 'You have passed your target for this date.';
  }

  DailyWaterModel copyWith({
    String? dateKey,
    int? totalMl,
    int? targetMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyWaterModel(
      dateKey: dateKey ?? this.dateKey,
      totalMl: totalMl ?? this.totalMl,
      targetMl: targetMl ?? this.targetMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'totalMl': totalMl,
      'targetMl': targetMl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyWaterModel.fromMap(Map<dynamic, dynamic> map) {
    return DailyWaterModel(
      dateKey: map['dateKey'] as String,
      totalMl: (map['totalMl'] as num?)?.toInt() ?? 0,
      targetMl: (map['targetMl'] as num?)?.toInt() ?? 2000,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}