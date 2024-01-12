import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NafasData extends StatefulWidget {
  final Widget child;

  const NafasData({Key? key, required this.child}) : super(key: key);

  @override
  _NafasDataState createState() => _NafasDataState();
}

extension on BuildContext {
  NafasDataWidget get data => NafasDataWidget.of(this)!;
}

class _NafasDataState extends State<NafasData> {
  late Future<bool> _appPreload;
  ThemeMode mode = ThemeMode.dark;
  ValueNotifier<int> activityIdRead = ValueNotifier(0);
  late FragmentProgram backgroundShader;

  @override
  void initState() {
    super.initState();
    _appPreload = _preloadApp();
  }

  Future<bool> _preloadApp() async {
    print('Loading background shader...');
    try {
      backgroundShader =
          await FragmentProgram.fromAsset('assets/shaders/background.frag');
    } catch (e) {
      print('Failed to load background shader: $e');
      rethrow;
    }
    print('Loading shared preferences...');
    var prefs = await SharedPreferences.getInstance();
    ThemeMode mode = ThemeMode.values[prefs.getInt('themeMode') ?? 2];
    this.mode = mode;
    int read = prefs.getInt('activityIdRead') ?? 0;
    activityIdRead.value = read;
    print('activityIdRead: $read');
    return true;
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      this.mode = mode;
      SharedPreferences.getInstance().then((value) async {
        await value.setInt('themeMode', mode.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _appPreload,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GlassTheme(
            data: mode == ThemeMode.dark
                ? const GlassThemeData.dark()
                : const GlassThemeData.light(),
            child: NafasDataWidget._(
              state: this,
              child: widget.child,
            ),
          );
        }
        return Container(
            child: const Center(
          child: CircularProgressIndicator(),
        ));
      },
    );
  }
}

class NafasDataWidget extends InheritedWidget {
  final _NafasDataState _state;

  const NafasDataWidget._({
    Key? key,
    required _NafasDataState state,
    required Widget child,
  })  : _state = state,
        super(key: key, child: child);

  void setThemeMode(ThemeMode mode) {
    _state.setThemeMode(mode);
  }

  FragmentProgram get backgroundShader => _state.backgroundShader;

  ThemeMode get themeMode => _state.mode;

  void toggleThemeMode() {
    setThemeMode(
        _state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  static NafasDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NafasDataWidget>();
  }

  @override
  bool updateShouldNotify(covariant NafasDataWidget oldWidget) {
    return _state != oldWidget._state;
  }
}
