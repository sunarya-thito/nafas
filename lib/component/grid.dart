import 'package:flutter/material.dart';

class Grid extends StatefulWidget {
  final Axis direction;
  final int crossAxisCount;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const Grid({
    Key? key,
    this.direction = Axis.vertical,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    required this.children,
  }) : super(key: key);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didUpdateWidget(covariant Grid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children) {
      _updateChildren();
    }
  }

  void _updateChildren() {
    if (widget.direction == Axis.horizontal) {
      _children.clear();
      int totalColumn = widget.children.length ~/ widget.crossAxisCount;
      if (widget.children.length % widget.crossAxisCount != 0) {
        totalColumn++;
      }
      List<List<Widget>> columns = List.generate(totalColumn, (index) => []);
      for (var i = 0; i < widget.children.length; i++) {
        int columnIndex = i ~/ widget.crossAxisCount;
        int rowIndex = i % widget.crossAxisCount;
        if (rowIndex > 0) {
          columns[columnIndex].add(SizedBox(height: widget.spacing));
        }
        columns[columnIndex].add(Expanded(child: widget.children[i]));
      }
      for (var i = 0; i < columns.length; i++) {
        if (i > 0) {
          _children.add(SizedBox(width: widget.runSpacing));
        }
        _children.add(Column(children: columns[i]));
      }
    } else {
      _children.clear();
      int totalRow = widget.children.length ~/ widget.crossAxisCount;
      if (widget.children.length % widget.crossAxisCount != 0) {
        totalRow++;
      }
      List<List<Widget>> rows = List.generate(totalRow, (index) => []);
      for (var i = 0; i < widget.children.length; i++) {
        int rowIndex = i ~/ widget.crossAxisCount;
        int columnIndex = i % widget.crossAxisCount;
        if (columnIndex > 0) {
          rows[rowIndex].add(SizedBox(width: widget.spacing));
        }
        rows[rowIndex].add(Expanded(child: widget.children[i]));
      }
      for (var i = 0; i < rows.length; i++) {
        if (i > 0) {
          _children.add(SizedBox(height: widget.runSpacing));
        }
        _children.add(Row(children: rows[i]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == Axis.horizontal) {
      return Row(
        children: _children,
      );
    } else {
      return Column(
        children: _children,
      );
    }
  }
}
