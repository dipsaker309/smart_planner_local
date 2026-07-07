import 'package:flutter/material.dart';

class ProgressSlider extends StatelessWidget {
  const ProgressSlider({
    super.key,
    required this.progress,
    required this.onChanged,
  });

  final int progress;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '$progress%',
            onChanged: (value) {
              onChanged(value.round());
            },
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$progress%',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}