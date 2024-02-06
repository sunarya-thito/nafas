import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/component/greeting.dart';
import 'package:nafas/component/grid.dart';
import 'package:nafas/component/lamp_color_picker.dart';
import 'package:nafas/component/page_section.dart';
import 'package:nafas/component/select_device_button.dart';
import 'package:nafas/component/sensor_card.dart';
import 'package:nafas/component/summary_activity_list.dart';
import 'package:nafas/main.dart';
import 'package:nafas/nafas_client_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return buildListView(context);
  }

  ListView buildListView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shrinkWrap: true,
      children: [
        Greeting(),
        const SizedBox(height: 32),
        SelectDeviceButton(),
        const SizedBox(
          height: 16,
        ),
        PageSection(
          title: Text('Summary'),
          action: IconButton(
            onPressed: () {
              context.pushNamed(kStatusPage);
            },
            icon: Icon(
              Icons.arrow_forward_ios,
            ),
          ),
          child: Grid(
            crossAxisCount: 2,
            runSpacing: 8,
            spacing: 8,
            // children: [
            //   for (var sensor in context.data.getSensorTypes().value)
            //     sensor.buil,
            // ],
            children: [
              SensorCard(
                  icon: Icon(Icons.ac_unit),
                  shortName: Text('Temp'),
                  value: TemperatureText(),
                  onTap: () {
                    context.pushNamed(kStatusDetailPage, queryParameters: {
                      'sensor': SensorType.temperature.name,
                    });
                  }),
              SensorCard(
                  icon: Icon(Icons.water_drop_outlined),
                  shortName: Text('Humid'),
                  value: HumidityText(),
                  onTap: () {
                    context.pushNamed(kStatusDetailPage, queryParameters: {
                      'sensor': SensorType.humidity.name,
                    });
                  }),
              SensorCard(
                icon: Icon(Icons.factory_outlined),
                shortName: Text('Dust'),
                value: DustText(),
                unit: Text('ppm'),
                onTap: () {
                  context.pushNamed(kStatusDetailPage, queryParameters: {
                    'sensor': SensorType.dust.name,
                  });
                },
              ),
              SensorCard(
                  icon: Icon(Icons.gas_meter_outlined),
                  shortName: Text('Methane'),
                  value: GasText(),
                  unit: Text('ppm'),
                  onTap: () {
                    context.pushNamed(kStatusDetailPage, queryParameters: {
                      'sensor': SensorType.gas.name,
                    });
                  }),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        PageSection(
          title: Text('Activity Log'),
          action: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_forward_ios),
          ),
          child: SummaryActivityList(
            showDeviceName: false,
            filter: ActivityFilter(devices: [
              if (context.currentDevice != null) context.currentDevice!,
            ]),
          ),
        ),
        PageSection(
          title: Text('Lamp Color'),
          child: LampColorPicker(),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
