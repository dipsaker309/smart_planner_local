import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text(AppDateUtils.formatWeekday(selectedDate)),
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
    );
  }
}
