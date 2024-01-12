import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

String formatNumber(num n, {int fractionDigits = 2}) {
  int intVal = n.toInt();
  if (intVal == n) {
    return intVal.toString();
  }
  return n.toStringAsFixed(fractionDigits);
}

extension NumberExtension on num {
  String format({int fractionDigits = 2}) {
    return formatNumber(this, fractionDigits: fractionDigits);
  }
}

String relativeTime(DateTime from, DateTime now) {
  int diff = now.difference(from).inSeconds;
  if (diff < 0) {
    return _relativeFutureTime(diff * -1);
  }
  if (diff < 60) {
    return '$diff ${diff == 1 ? 'second' : 'seconds'} ago';
  }
  if (diff < 60 * 60) {
    int minutes = diff ~/ 60;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (diff < 60 * 60 * 24) {
    int hours = diff ~/ (60 * 60);
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
  // return dd/MM/yyyy hh:mm
  return '${from.day}/${from.month}/${from.year} ${from.hour}:${from.minute}';
}

Widget emptyPageBuilder(BuildContext context) {
  return Container(
    height: 54,
    alignment: Alignment.center,
    child: Text(
      'No data',
      style: TextStyle(
        color: context.theme.secondaryTextColor,
      ),
    ),
  );
}

List<Widget> joinWidgets(List<Widget> widgets, Widget separator) {
  List<Widget> result = [];
  for (int i = 0; i < widgets.length; i++) {
    result.add(widgets[i]);
    if (i < widgets.length - 1) {
      result.add(separator);
    }
  }
  return result;
}

String _relativeFutureTime(int diff) {
  if (diff < 60) {
    return 'in $diff seconds';
  }
  if (diff < 60 * 60) {
    int minutes = diff ~/ 60;
    return 'in $minutes minutes';
  }
  if (diff < 60 * 60 * 24) {
    int hours = diff ~/ (60 * 60);
    return 'in $hours hours';
  }
  return 'in ${diff ~/ (60 * 60 * 24)} days';
}
