import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/local/models/daily_water_model.dart';
import '../../../data/local/repositories/wellness_repository.dart';

final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) {
  return WellnessRepository();
});

final wellnessControllerProvider =
    NotifierProvider<WellnessController, WellnessState>(
  WellnessController.new,
);

class WellnessState {
  const WellnessState({
    required this.selectedDate,
    required this.water,
    this.isLoading = false,
    this.message,
  });

  final DateTime selectedDate;
  final DailyWaterModel water;
  final bool isLoading;
  final String? message;

  WellnessState copyWith({
    DateTime? selectedDate,
    DailyWaterModel? water,
    bool? isLoading,
    String? message,
    bool clearMessage = false,
  }) {
    return WellnessState(
      selectedDate: selectedDate ?? this.selectedDate,
      water: water ?? this.water,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

class WellnessController extends Notifier<WellnessState> {
  WellnessRepository get _repository => ref.read(wellnessRepositoryProvider);

  @override
  WellnessState build() {
    final today = AppDateUtils.today();
    final water = _repository.getWaterForDate(today);

    return WellnessState(
      selectedDate: today,
      water: water,
    );
  }

  void loadForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final water = _repository.getWaterForDate(normalizedDate);

    state = state.copyWith(
      selectedDate: normalizedDate,
      water: water,
      clearMessage: true,
    );
  }

  Future<void> addWater(int amountMl) async {
    if (amountMl <= 0) {
      state = state.copyWith(
        message: 'Please enter a valid water amount.',
      );
      return;
    }

    await _repository.addWater(
      date: state.selectedDate,
      amountMl: amountMl,
    );

    _refreshWater(
      message: 'Added $amountMl ml water.',
    );
  }

  Future<void> setWaterTotal(int totalMl) async {
    if (totalMl < 0) {
      state = state.copyWith(
        message: 'Water amount cannot be negative.',
      );
      return;
    }

    await _repository.setWaterTotal(
      date: state.selectedDate,
      totalMl: totalMl,
    );

    _refreshWater(
      message: 'Water total updated.',
    );
  }

  Future<void> updateWaterTarget(int targetMl) async {
    if (targetMl <= 0) {
      state = state.copyWith(
        message: 'Target must be greater than 0 ml.',
      );
      return;
    }

    await _repository.updateWaterTarget(
      date: state.selectedDate,
      targetMl: targetMl,
    );

    _refreshWater(
      message: 'Water target updated.',
    );
  }

  Future<void> resetWater() async {
    await _repository.resetWater(state.selectedDate);

    _refreshWater(
      message: 'Water intake reset for this date.',
    );
  }

  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }

  void _refreshWater({String? message}) {
    final updatedWater = _repository.getWaterForDate(state.selectedDate);

    state = state.copyWith(
      water: updatedWater,
      message: message,
    );
  }
}