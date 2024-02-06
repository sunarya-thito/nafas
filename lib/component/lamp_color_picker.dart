import 'package:flutter/material.dart';
import 'package:nafas/app_data.dart';
import 'package:nafas/nafas_client_app.dart';

import 'color_picker.dart';

class LampColorPicker extends StatefulWidget {
  const LampColorPicker({Key? key}) : super(key: key);

  @override
  _LampColorPickerState createState() => _LampColorPickerState();
}

class _LampColorPickerState extends State<LampColorPicker> {
  @override
  Widget build(BuildContext context) {
    return context.nafasClient.device.build(
      builder: (context, value) {
        if (value == null) {
          return Container();
        }
        return ColorSessionBuilder(
          key: ValueKey(value),
          builder: (context, color, setColor) {
            return Material(
              color: Colors.transparent,
              child: Theme(
                data: NafasDataWidget.of(context)!.themeMode == ThemeMode.light
                    ? ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.light(
                          primary: Colors.black,
                          secondary: Colors.black,
                          surface: Colors.white,
                        ),
                      )
                    : ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.dark(
                          primary: Colors.white,
                          secondary: Colors.white,
                          surface: Colors.black,
                        ),
                      ),
                child: ColorPicker(
                  color: color,
                  pickerOrientation: PickerOrientation.portrait,
                  initialPicker: Picker.wheel,
                  onChanged: (value) {
                    setState(() {
                      setColor(value);
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
