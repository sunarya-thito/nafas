import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nafas/component/activity_tile.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

import '../util.dart';

Map<String, String> _nameMapping = {
  'temperature_high': 'High Temperature',
  'temperature_low': 'Low Temperature',
  'humidity_high': 'High Humidity',
  'humidity_low': 'Low Humidity',
  'co2_high': 'High CO2',
  'co2_low': 'Low CO2',
  'methane_high': 'High Methane',
  'methane_low': 'Low Methane',
  'dust_high': 'High Dust',
  'dust_low': 'Low Dust',
  'sensor_online': 'Online',
  'sensor_offline': 'Offline',
};

Map<String, Widget> _iconMapping = {
  'temperature_high': const Icon(Icons.thermostat),
  'temperature_low': const Icon(Icons.thermostat),
  'humidity_high': const Icon(Icons.water_drop_outlined),
  'humidity_low': const Icon(Icons.water_drop_outlined),
  'co2_high': const Icon(Icons.cloud_outlined),
  'co2_low': const Icon(Icons.cloud_outlined),
  'methane_high': const Icon(Icons.gas_meter_outlined),
  'methane_low': const Icon(Icons.gas_meter_outlined),
  'dust_high': const Icon(Icons.factory_outlined),
  'dust_low': const Icon(Icons.factory_outlined),
  'sensor_online': const Icon(Icons.wifi),
  'sensor_offline': const Icon(Icons.wifi_off),
};

Map<SensorType, String> _unitMapping = {
  SensorType.gas: 'ppm',
  SensorType.dust: 'µg/m³',
  SensorType.humidity: '%',
  SensorType.temperature: '°C',
};

Map<String, SensorType> _typeMapping = {
  'temperature_high': SensorType.temperature,
  'temperature_low': SensorType.temperature,
  'humidity_high': SensorType.humidity,
  'humidity_low': SensorType.humidity,
  'co2_high': SensorType.co2,
  'co2_low': SensorType.co2,
  'sensor_online': SensorType.network,
  'sensor_offline': SensorType.network,
  'dust_high': SensorType.dust,
  'dust_low': SensorType.dust,
};

class StandardActivityTile extends StatefulWidget {
  final ActivityData data;
  final bool showDeviceName;

  const StandardActivityTile({
    Key? key,
    required this.data,
    this.showDeviceName = false,
  }) : super(key: key);

  @override
  State<StandardActivityTile> createState() => _StandardActivityTileState();
}

class _StandardActivityTileState extends State<StandardActivityTile>
    with SingleTickerProviderStateMixin {
  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {});
      }
    });
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  String get header {
    var deviceName = widget.data.device;
    var time = DateTime.fromMillisecondsSinceEpoch(widget.data.timestamp);
    // Date - Device Name
    // date format: dd/MM/yyyy HH:mm
    if (widget.showDeviceName) {
      // return '${relativeTime(activity.data.time, DateTime.now())} - ${activity.device.name}';
      return '${relativeTime(time, DateTime.now())} - $deviceName';
    }
    // return relativeTime(activity.data.time, DateTime.now());
    return relativeTime(time, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTile(
      header: Text(header),
      content: Text(_nameMapping[widget.data.type] ?? widget.data.type),
      icon: ActivityReadMarker(
        activity: widget.data,
        child: _iconMapping[widget.data.type] ?? const Icon(Icons.error),
      ),
      trailing: _unitMapping[_typeMapping[widget.data.type]] == null
          ? DefaultTextStyle(
              style: TextStyle(
                fontSize: 18,
                color: context.theme.secondaryTextColor,
              ),
              child: Text(
                widget.data.device,
              ),
            )
          : Text(
              '${formatNumber(widget.data.value, fractionDigits: 2)}${_unitMapping[_typeMapping[widget.data.type]]}',
              style: TextStyle(
                fontSize: 18,
                color: context.theme.secondaryTextColor,
              ),
            ),
    );
  }
}
