import 'dart:ui';

import 'package:flutter/material.dart';

enum FetchMode {
  append,
  prepend,
  replace,
}

class PaginationController<T> extends ChangeNotifier {
  final List<T> _data = [];
  final Future<List<T>> Function(T? lastItem) fetchPage;

  Future<List<T>>? _future;

  int _futureId = 0;

  PaginationController({
    required this.fetchPage,
  });

  void reset() {
    _future = null;
    _futureId++;
    _data.clear();
    notifyListeners();
  }
}

class PaginatedListView<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item) builder;
  final Widget separator;
  final Widget Function(BuildContext context, T? lastItem)? loadingBuilder;
  final Widget Function(BuildContext context, T? lastItem)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final bool reverse;
  final FetchMode fetchMode;
  final ScrollController? scrollController;

  const PaginatedListView({
    Key? key,
    required this.controller,
    required this.builder,
    required this.separator,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.reverse = false,
    this.fetchMode = FetchMode.append,
    this.scrollController,
  }) : super(key: key);

  @override
  _PaginatedListViewState<T> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  List<T> get _data => widget.controller._data;
  Future<List<T>>? get _future => widget.controller._future;
  set _future(Future<List<T>>? value) => widget.controller._future = value;

  @override
  void initState() {
    super.initState();
    _future = fetchNext();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
  }

  void _update() {
    setState(() {});
  }

  Future<List<T>> fetchNext() {
    if (_future != null) {
      return _future!;
    }
    T? lastItem = _data.lastOrNull;
    int futureId = ++widget.controller._futureId;
    var future = widget.controller.fetchPage(lastItem).then((value) {
      if (value.isEmpty) {
        return _data;
      }
      setState(() {
        if (futureId != widget.controller._futureId) {
          return;
        }
        // _data.addAll(value);
        switch (widget.fetchMode) {
          case FetchMode.append:
            _data.addAll(value);
            break;
          case FetchMode.prepend:
            _data.insertAll(0, value);
            break;
          case FetchMode.replace:
            _data.clear();
            _data.addAll(value);
            break;
        }
        _future = null;
      });
      return _data;
    });
    _future = future;
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
        },
      ),
      child: ListView.separated(
          controller: widget.scrollController,
          reverse: widget.reverse,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == _data.length) {
              return FutureBuilder<List<T>>(
                future: fetchNext(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return widget.loadingBuilder
                            ?.call(context, _data.lastOrNull) ??
                        Container();
                  } else if (snapshot.hasError) {
                    return widget.errorBuilder
                            ?.call(context, _data.lastOrNull) ??
                        Container();
                  } else {
                    return widget.loadingBuilder
                            ?.call(context, _data.lastOrNull) ??
                        Container();
                  }
                },
              );
            }
            return widget.builder(context, _data[index]);
          },
          separatorBuilder: (context, index) {
            return widget.separator;
          },
          itemCount: _data.length + 1),
    );
  }
}
