import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/component/page_section.dart';
import 'package:nafas/component/select_device_button.dart';
import 'package:nafas/component/sensor_tile.dart';

import '../main.dart';
import '../nafas_client_app.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        // SensorDeviceDropdown(),
        SelectDeviceButton(),
        const SizedBox(
          height: 24,
        ),
        PageSection(
          title: Text('Status'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // children: [
            //   for (var sensor in context.data.getSensorTypes().value)
            //     Padding(
            //       padding: EdgeInsets.symmetric(vertical: 4),
            //       child: ,
            //     ),
            // ],
            // children: context.data
            //     .getSensorTypes()
            //     .value
            //     .map((e) => e.buildListTile(context, context.selectedDevice))
            //     .nonNulls
            //     .map((e) => Padding(
            //           padding: const EdgeInsets.symmetric(vertical: 4),
            //           child: e,
            //         ))
            //     .toList(),
            children: [
              SensorTile(
                icon: Icon(Icons.ac_unit),
                header: Text('Temperature'),
                content: TemperatureText(),
                action: () {
                  context.pushNamed(kStatusDetailPage, queryParameters: {
                    'sensor': SensorType.temperature.name,
                  });
                },
              ),
              const SizedBox(
                height: 8,
              ),
              SensorTile(
                icon: Icon(Icons.water_drop_outlined),
                header: Text('Humidity'),
                content: HumidityText(),
                action: () {
                  context.pushNamed(kStatusDetailPage, queryParameters: {
                    'sensor': SensorType.humidity.name,
                  });
                },
              ),
              const SizedBox(
                height: 8,
              ),
              SensorTile(
                icon: Icon(Icons.factory_outlined),
                header: Text('Dust'),
                content: DustText(showUnit: true),
                action: () {
                  context.pushNamed(kStatusDetailPage,
                      queryParameters: {'sensor': SensorType.dust.name});
                },
              ),
              const SizedBox(
                height: 8,
              ),
              // Gas
              SensorTile(
                icon: Icon(Icons.gas_meter_outlined),
                header: Text('Methane'),
                content: GasText(showUnit: true),
                action: () {
                  context.pushNamed(kStatusDetailPage,
                      queryParameters: {'sensor': SensorType.gas.name});
                },
              ),
              const SizedBox(
                height: 8,
              ),
              // CO2
              SensorTile(
                icon: Icon(Icons.cloud_outlined),
                header: Text('CO2'),
                content: CO2Text(showUnit: true),
                action: () {
                  context.pushNamed(kStatusDetailPage,
                      queryParameters: {'sensor': SensorType.co2.name});
                },
              ),
              // const SizedBox(
              //   height: 8,
              // ),
              // SensorTile(
              //   icon: Icon(Icons.sensors_outlined),
              //   header: Text('Sensor'),
              //   content: NetworkText(),
              //   action: () {
              //     context.pushNamed(kStatusDetailPage, queryParameters: {
              //       'sensor': SensorType.network.name,
              //     });
              //   },
              // )
            ],
          ),
        ),
      ],
    );
  }
}
