import 'package:flutter/material.dart';

class Rebuilder extends StatefulWidget {
  final Duration interval;
  final Widget child;
  const Rebuilder({
    Key? key,
    this.interval = const Duration(seconds: 1),
    required this.child,
  }) : super(key: key);
  @override
  _RebuilderState createState() => _RebuilderState();
}

class _RebuilderState extends State<Rebuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double previousValue = 0;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.interval)
      ..repeat();
    super.initState();
    _controller.addListener(() {
      if (previousValue > _controller.value) {
        setState(() {
          _rebuildCount++;
        });
      }
      previousValue = _controller.value;
    });
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void didUpdateWidget(covariant Rebuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) {
      _controller.duration = widget.interval;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return DataRebuilder(
      rebuildCount: _rebuildCount,
      child: widget.child,
    );
  }
}

class DataRebuilder extends InheritedWidget {
  final int rebuildCount;

  const DataRebuilder({
    Key? key,
    required this.rebuildCount,
    required Widget child,
  }) : super(key: key, child: child);

  static DataRebuilder? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataRebuilder>();
  }

  @override
  bool updateShouldNotify(covariant DataRebuilder oldWidget) {
    return rebuildCount != oldWidget.rebuildCount;
  }
}
