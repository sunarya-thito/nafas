import 'package:flutter/material.dart';
import 'package:nafas/component/standard_activity_tile.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/util.dart';

class SummaryActivityList extends StatelessWidget {
  final ActivityFilter filter;
  final bool showDeviceName;
  final int limit;

  const SummaryActivityList({
    Key? key,
    required this.filter,
    required this.showDeviceName,
    this.limit = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.nafasClient.device.build(
      builder: (context, selectedDevice) {
        if (selectedDevice == null) {
          return Container();
        }
        return SummaryActivityListBuilder(
            filter: filter,
            shrinkWrap: true,
            emptyBuilder: emptyPageBuilder,
            builder: (context, activity) {
              return StandardActivityTile(
                data: activity,
                showDeviceName: showDeviceName,
              );
            },
            limit: limit);
      },
    );
  }
}
