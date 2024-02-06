import 'package:flutter/material.dart';
import 'package:nafas/app_data.dart';
import 'package:nafas/theme.dart';

class ThemeModeToggler extends StatefulWidget {
  const ThemeModeToggler({Key? key}) : super(key: key);

  @override
  _ThemeModeTogglerState createState() => _ThemeModeTogglerState();
}

class _ThemeModeTogglerState extends State<ThemeModeToggler> {
  @override
  Widget build(BuildContext context) {
    return NafasDataWidget.of(context)?.themeMode == ThemeMode.dark
        ? Icon(
            Icons.dark_mode,
            color: context.theme.secondaryTextColor,
          )
        : Icon(
            Icons.light_mode,
            color: context.theme.secondaryTextColor,
          );
  }
}
