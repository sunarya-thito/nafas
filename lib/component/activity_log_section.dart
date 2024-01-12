import 'package:flutter/material.dart';
import 'package:nafas/component/page_section.dart';

enum Filter {
  selectedDevice,
  fromDate,
  toDate,
  dataType,
}

class ActivityLogSection extends StatelessWidget {
  final List<Filter> filters;

  const ActivityLogSection({
    Key? key,
    this.filters = const [
      Filter.selectedDevice,
      Filter.fromDate,
      Filter.toDate,
      Filter.dataType,
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: Text('Activity Log'),
      action: IconButton(
        onPressed: () {},
        iconSize: 24,
        icon: Icon(
          Icons.filter_alt,
        ),
      ),
      // child: ListView(
      //     // children: joinWidgets(, separator),
      //     ),
    );
  }
}
