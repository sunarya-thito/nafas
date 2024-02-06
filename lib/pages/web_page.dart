import 'package:flutter/material.dart';
import 'package:nafas/component/background_blob.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/component/greeting.dart';
import 'package:nafas/component/lamp_color_picker.dart';
import 'package:nafas/component/page_section.dart';
import 'package:nafas/component/web_sensor_stats.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

import '../component/summary_activity_list.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBlob(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  GlassPane(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Greeting(),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  PageSection(
                    title: Text('Devices'),
                    child: context.nafasClient.device.build(
                      builder: (context, selectedDevice) {
                        return DeviceListBuilder(
                          builder: (context, devices) {
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: devices.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 4,
                                );
                              },
                              itemBuilder: (context, index) {
                                final device = devices[index];
                                return GlassPaneInkWell(
                                  onTap: () {
                                    context.nafasClient.connect(device);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              DefaultTextStyle(
                                                  style: TextStyle(
                                                    color: context.theme
                                                        .secondaryTextColor,
                                                    fontSize: 12,
                                                  ),
                                                  child: device.isOnline.build(
                                                    builder:
                                                        (context, isOnline) {
                                                      if (selectedDevice ==
                                                          device) {
                                                        return Text(isOnline
                                                            ? 'Online - Selected'
                                                            : 'Offline - Selected');
                                                      } else {
                                                        return Text(isOnline
                                                            ? 'Online'
                                                            : 'Offline');
                                                      }
                                                    },
                                                  )),
                                              DefaultTextStyle(
                                                style: TextStyle(
                                                  color: context
                                                      .theme.primaryTextColor,
                                                  fontSize: 20,
                                                ),
                                                child: DynamicText(
                                                  value: device.name,
                                                  formatter: (value) => value,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  PageSection(
                    title: Text('Lamp Color'),
                    child: LampColorPicker(),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: WebSensorStats(
                              title: Text('Temperature'),
                              sensorType: SensorType.temperature,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: WebSensorStats(
                              title: Text('Humidity'),
                              sensorType: SensorType.humidity,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: WebSensorStats(
                              title: Text('Dust'),
                              sensorType: SensorType.dust,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: WebSensorStats(
                              title: Text('CO2'),
                              sensorType: SensorType.co2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: WebSensorStats(
                              title: Text('Methane'),
                              sensorType: SensorType.gas,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              flex: 1,
              child: FilteredActivity(),
            ),
          ],
        ),
      ),
    );
  }
}

class FilteredActivity extends StatefulWidget {
  const FilteredActivity({
    super.key,
  });

  @override
  State<FilteredActivity> createState() => _FilteredActivityState();
}

class _FilteredActivityState extends State<FilteredActivity> {
  bool _showOnlyFromDevice = false;
  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: Text('Activity Log'),
      action: IconButton(
        onPressed: () {
          setState(() {
            _showOnlyFromDevice = !_showOnlyFromDevice;
          });
        },
        icon: Icon(
          _showOnlyFromDevice
              ? Icons.filter_alt
              : Icons.filter_alt_off_outlined,
        ),
      ),
      child: Expanded(
        child: context.nafasClient.device.build(
          builder: (context, value) {
            if (value == null) {
              return Container();
            }
            return SummaryActivityList(
                filter: ActivityFilter(
                  devices: _showOnlyFromDevice ? [value] : null,
                ),
                showDeviceName: !_showOnlyFromDevice,
                limit: 100);
          },
        ),
      ),
    );
  }
}
