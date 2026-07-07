import 'package:flutter/material.dart';

class ProgressSlider extends StatelessWidget {
  const ProgressSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value.clamp(0, 1),
      onChanged: onChanged,
    );
  }
}
