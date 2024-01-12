import 'package:flutter/material.dart';
import 'package:nafas/component/detail_header.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/component/standard_sub_page.dart';
import 'package:nafas/component/summary_activity_list.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

class StatusDetailPage extends StatefulWidget {
  // final SensorType type;
  // final SensorDevice device;
  final SensorType type;
  final bool showForecast;

  const StatusDetailPage({
    Key? key,
    required this.type,
    this.showForecast = true,
    // required this.device,
  }) : super(key: key);

  @override
  _StatusDetailPageState createState() => _StatusDetailPageState();
}

class _StatusDetailPageState extends State<StatusDetailPage> {
  @override
  Widget build(BuildContext context) {
    // var detailsPage = type.buildDetailsPage(context, sensor);
    return SensorDetailScope(
      type: widget.type,
      child: StandardSubPage(
        header: Text(widget.type.displayName),
        title: CurrentDeviceText(),
        child: ListView(
          children: [
            RecordedDataTimeRangePopupMenu(
              itemBuilder: (context, range) {
                return DetailHeader(
                  title: Text(range),
                  header: Text('Recorded Data'),
                  trailing: Icon(Icons.expand_more),
                );
              },
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: 300,
              child: SensorSessionChart(
                border: Border.all(
                  color: context.theme.surfaceBorderColor,
                ),
                titleColor: context.theme.secondaryTextColor,
                gridColor: context.theme.surfaceBorderColor,
              ),
            ),
            if (widget.showForecast)
              const SizedBox(
                height: 24,
              ),
            if (widget.showForecast)
              ForecastTypePopupMenu(itemBuilder: (context, range) {
                return DetailHeader(
                  title: Text(range),
                  header: Text('Forecast'),
                  trailing: Icon(Icons.expand_more),
                );
              }),
            if (widget.showForecast)
              const SizedBox(
                height: 24,
              ),
            if (widget.showForecast)
              SizedBox(
                height: 300,
                child: SensorForecastingChart(
                  sensor: widget.type,
                  border: Border.all(
                    color: context.theme.surfaceBorderColor,
                  ),
                  titleColor: context.theme.secondaryTextColor,
                  gridColor: context.theme.surfaceBorderColor,
                ),
              ),
            const SizedBox(
              height: 24,
            ),
            Container(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _buildTile(
                        header: Text('Current'),
                        content: SensorValueText(type: widget.type)),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildTile(
                        header: Text('Min'),
                        content: SensorLowestValueText(type: widget.type)),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildTile(
                        header: Text('Max'),
                        content: SensorHighestValueText(type: widget.type)),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildTile(
                        header: Text('Average'),
                        content: SensorAverageValueText(type: widget.type)),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              'Activity',
              style: context.theme.secondaryText(
                fontSize: 20,
              ),
            ),
            context.nafasClient.device.build(
              builder: (context, value) {
                return SummaryActivityList(
                    showDeviceName: false,
                    filter: ActivityFilter(devices: [
                      if (value != null) value,
                    ], sensors: [
                      widget.type,
                    ]));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required Widget header, required Widget content}) {
    return Expanded(
      child: GlassPane(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: context.theme.secondaryText(
                  fontSize: 12,
                ),
                child: header,
              ),
              DefaultTextStyle(
                style: context.theme.text(
                  fontSize: 20,
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
