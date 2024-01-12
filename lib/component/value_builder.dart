import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DynamicText extends StatelessWidget {
  final ValueListenable<dynamic>? value;
  final String Function(dynamic value)? formatter;

  const DynamicText({super.key, required this.value, this.formatter});

  @override
  Widget build(BuildContext context) {
    var value = this.value;
    if (value == null) {
      return const Text('');
    }
    return ValueListenableBuilder(
      valueListenable: value,
      builder: (context, value, child) {
        String? valueString = formatter?.call(value) ?? value?.toString();
        return Text(valueString ?? '');
      },
    );
  }
}
