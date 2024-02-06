import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const verbose = true;
String kScheme = 'http';
String kBaseHostname = "localhost";
int? kBasePort = 8081;
const kSensorTemperature = "temp";
const kSensorHumidity = "humid";
const kSensorCO2 = "co2";
const kSensorGas = "gas";
const kSensorDust = "dust";
const kSensorNetwork = "network";
const kSensorAirQualityIndex = "aqi";
const kPacketOutboundData = "PacketOutboundData";
const kPacketOutboundActivity = "PacketOutboundActivity";
const kPacketOutboundConfig = "PacketOutboundConfig";
const kPacketOutboundDeviceRename = "PacketOutboundDeviceRename";
const kPacketInboundColor = "PacketInboundColor";
const kPacketOutboundColor = "PacketOutboundColor";
const kRoleAdmin = "admin";
const kRoleUser = "user";
const kAPIResponseError = "APIResponseError";
const kAPIResponseLoginSuccess = "APIResponseLoginSuccess";
const kAPIResponseLogoutSuccess = "APIResponseLogoutSuccess";
const kAPIResponseDevices = "APIResponseDevices";
const kAPIResponseConfig = "APIResponseConfig";
const kAPIResponseActivities = "APIResponseActivities";
const kAPIResponseData = "APIResponseData";
const kAPIResponseForecast = "APIResponseForecast";
const kAPIResponseSuccess = "APIResponseSuccess";
const kAPIResponseSensorValues = "APIResponseSensorValues";
const kAPIResponseColor = "APIResponseColor";

const kAPIRequestSensorValues = "APIRequestSensorValues";
const kAPIRequestChangeConfig = "APIRequestChangeConfig";
const kAPIRequestLogin = "APIRequestLogin";
const kAPIRequestLogout = "APIRequestLogout";
const kAPIRequestConfig = "APIRequestConfig";
const kAPIRequestDevices = "APIRequestDevices";
const kAPIRequestActivities = "APIRequestActivities";
const kAPIRequestData = "APIRequestData";
const kAPIRequestForecast = "APIRequestForecast";
const kAPIRequestBeepDevice = "APIRequestBeepDevice";
const kAPIRequestRenameDevice = "APIRequestRenameDevice";
const kAPIRequestColor = "APIRequestColor";

const kActivityCO2High = "co2_high";
const kActivityCO2Low = "co2_low";
const kActivityDustHigh = "dust_high";
const kActivityDustLow = "dust_low";
const kActivityHumidityHigh = "humidity_high";
const kActivityHumidityLow = "humidity_low";
const kActivityTemperatureHigh = "temperature_high";
const kActivityTemperatureLow = "temperature_low";
const kActivityGasHigh = "gas_high";
const kActivityGasLow = "gas_low";
const kActivitySensorOffline = "sensor_offline";
const kActivitySensorOnline = "sensor_online";

void debug(Object? message) {
  if (verbose) {
    print(message);
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
          child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                )),
          ],
        ),
      )),
    );
  }
}

class NafasClientApp extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context)? loadingBuilder;

  const NafasClientApp({
    Key? key,
    required this.child,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  State<NafasClientApp> createState() => _NafasClientAppState();
}

class _NafasClientAppState extends State<NafasClientApp> {
  late NafasClient _client;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _client = NafasClient();
    _initFuture = _client.initialize().onError((error, stackTrace) {
      debug(error);
      debug(stackTrace);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              DataWidget<NafasClient>(
                data: _client,
                child: widget.child,
              ),
              if (snapshot.connectionState != ConnectionState.done)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: widget.loadingBuilder?.call(context) ??
                        const LoadingOverlay(),
                  ),
                )
            ],
          );
          // if (snapshot.connectionState == ConnectionState.done) {
          //   return DataWidget<NafasClient>(
          //     data: _client,
          //     child: widget.child,
          //   );
          // } else {
          //   // return widget.loadingBuilder?.call(context) ?? const LoadingOverlay();
          //
          // }
        },
      ),
    );
  }
}

class ActivityData {
  final int id;
  final String type;
  final int timestamp;
  final String device;
  final String sensor;
  final double value;

  const ActivityData({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.device,
    required this.sensor,
    required this.value,
  });
}

class DataEntry {
  final int timestamp;
  final double value;

  const DataEntry({
    required this.timestamp,
    required this.value,
  });
}

enum SensorType {
  temperature(
      kSensorTemperature,
      kActivityTemperatureHigh,
      kActivityTemperatureLow,
      SensorConfiguration(min: 15, max: 30),
      'Temperature',
      true),
  humidity(kSensorHumidity, kActivityHumidityHigh, kActivityHumidityLow,
      SensorConfiguration(min: 30, max: 70), 'Humidity', true),
  co2(kSensorCO2, kActivityCO2High, kActivityCO2Low,
      SensorConfiguration(min: 0, max: 1000), 'CO2', false),
  gas(kSensorGas, kActivityGasHigh, kActivityGasLow,
      SensorConfiguration(min: 0, max: 1000), 'Methane', false),
  dust(kSensorDust, kActivityDustHigh, kActivityDustLow,
      SensorConfiguration(min: 0, max: 1000), 'Dust', false),
  network(kSensorNetwork, kActivitySensorOnline, kActivitySensorOffline,
      SensorConfiguration(min: -1, max: -1), 'Sensor', false),
  airQualityIndex(kSensorAirQualityIndex, kActivityCO2High, kActivityCO2Low,
      SensorConfiguration(min: 0, max: 1000), 'Air Quality Index', false);

  final String id;
  final String highActivity;
  final String lowActivity;
  final String displayName;
  final bool showForecast;

  final SensorConfiguration defaultConfiguration;

  const SensorType(this.id, this.highActivity, this.lowActivity,
      this.defaultConfiguration, this.displayName, this.showForecast);

  static SensorType? fromId(String id) {
    for (SensorType type in SensorType.values) {
      if (type.id == id) {
        return type;
      }
    }
    return null;
  }
}

class ActivityFilter {
  final List<Device>? devices;
  final int? fromDate;
  final int? toDate;
  final List<SensorType>? sensors;

  ActivityFilter({
    this.devices,
    this.fromDate,
    this.toDate,
    this.sensors,
  });

  bool accepts(ActivityData activity) {
    if (devices != null &&
        !devices!.any((element) => element.id == activity.device)) {
      return false;
    }
    if (sensors != null &&
        !sensors!.any((element) => element.id == activity.sensor)) {
      return false;
    }
    if (fromDate != null && activity.timestamp < fromDate!) {
      return false;
    }
    if (toDate != null && activity.timestamp > toDate!) {
      return false;
    }
    return true;
  }

  ActivityFilter copyWith({
    List<Device>? devices,
    int? fromDate,
    int? toDate,
    List<SensorType>? sensors,
  }) {
    return ActivityFilter(
      devices: devices ?? this.devices,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      sensors: sensors ?? this.sensors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ActivityFilter) {
      return ListEquality().equals(devices, other.devices) &&
          fromDate == other.fromDate &&
          toDate == other.toDate &&
          ListEquality().equals(sensors, other.sensors);
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(devices, fromDate, toDate, sensors);
}

class DataWidget<T> extends InheritedWidget {
  final T data;

  const DataWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static DataWidget<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataWidget<T>>();
  }

  @override
  bool updateShouldNotify(covariant DataWidget<T> oldWidget) {
    return data != oldWidget.data;
  }
}

class ActivityListBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ActivityData activity) builder;
  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(BuildContext context, String error) errorBuilder;
  final Widget Function(BuildContext context) emptyBuilder;
  final Widget Function(BuildContext context) noMoreBuilder;
  final Widget Function(BuildContext context) separatorBuilder;

  const ActivityListBuilder({
    Key? key,
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
    required this.noMoreBuilder,
    required this.separatorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<List<ActivityData>>(
      valueListenable: client._activities,
      builder: (context, activities, _) {
        if (activities.isEmpty) {
          if (client._activityFuture.value != null) {
            return loadingBuilder(context);
          } else {
            return emptyBuilder(context);
          }
        }
        return ListView.separated(
          itemBuilder: (context, index) {
            if (index >= activities.length) {
              if (client._activityFuture.value != null) {
                return loadingBuilder(context);
              } else {
                return noMoreBuilder(context);
              }
            }
            return builder(context, activities[index]);
          },
          separatorBuilder: (context, index) {
            return separatorBuilder(context);
          },
          itemCount: client._activityLastId.value == -1
              ? activities.length
              : activities.length + 1,
        );
      },
    );
  }
}

Widget defaultLoadingBuilder(BuildContext context) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

Widget defaultEmptyBuilder(BuildContext context) {
  return const Center(
    child: Text('No activities'),
  );
}

Widget defaultNoMoreBuilder(BuildContext context) {
  return const Center(
    child: Text('No more activities'),
  );
}

Widget defaultSeparatorBuilder(BuildContext context) {
  return const SizedBox(
    height: 8,
  );
}

// same as ActivityListBuilder, but only shows 5 activities
class SummaryActivityListBuilder extends StatefulWidget {
  final ActivityFilter filter;
  final int limit;
  final Widget Function(BuildContext context, ActivityData activity) builder;
  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(BuildContext context) emptyBuilder;
  final Widget Function(BuildContext context) separatorBuilder;
  final bool shrinkWrap;

  SummaryActivityListBuilder({
    Key? key,
    this.shrinkWrap = false,
    required this.filter,
    required this.builder,
    this.loadingBuilder = defaultLoadingBuilder,
    required this.limit,
    this.emptyBuilder = defaultEmptyBuilder,
    this.separatorBuilder = defaultSeparatorBuilder,
  }) : super(key: key);

  @override
  _SummaryActivityListBuilderState createState() =>
      _SummaryActivityListBuilderState();
}

class _SummaryActivityListBuilderState
    extends State<SummaryActivityListBuilder> {
  ActivityListSession? _session;
  NafasClient? _client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NafasClient newClient = DataWidget.of<NafasClient>(context)!.data;
    if (newClient != _client) {
      _client = newClient;
      _session?.dispose();
      _session = null;
      _session ??= newClient.createActivityListSession(
          limit: widget.limit, filter: widget.filter);
    }
  }

  @override
  void didUpdateWidget(covariant SummaryActivityListBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter || oldWidget.limit != widget.limit) {
      _session?.dispose();
      _session = _client!.createActivityListSession(
          limit: widget.limit, filter: widget.filter);
    }
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _session!.loading,
      builder: (context, loading, _) {
        if (loading) {
          return widget.loadingBuilder(context);
        }
        return ValueListenableBuilder<List<ActivityData>>(
          valueListenable: _session!.activities,
          builder: (context, activities, _) {
            if (activities.isEmpty) {
              return widget.emptyBuilder(context);
            }
            return ListView.separated(
              shrinkWrap: widget.shrinkWrap,
              itemBuilder: (context, index) {
                if (index >= activities.length) {
                  return widget.loadingBuilder(context);
                }
                return widget.builder(
                    context, activities[activities.length - index - 1]);
              },
              separatorBuilder: (context, index) {
                return widget.separatorBuilder(context);
              },
              itemCount: activities.length,
            );
          },
        );
      },
    );
  }
}

extension NafasExtension on BuildContext {
  NafasClient get nafasClient => DataWidget.of<NafasClient>(this)!.data;
  Device? get currentDevice => nafasClient._currentDevice.value;
}

class SensorDetailScope extends StatefulWidget {
  final SensorType type;
  final int? duration;
  final Device? device;
  final Widget child;

  const SensorDetailScope({
    Key? key,
    required this.type,
    required this.child,
    this.device,
    this.duration,
  }) : super(key: key);

  @override
  _SensorDetailScopeState createState() => _SensorDetailScopeState();
}

class _SensorDetailScopeState extends State<SensorDetailScope> {
  SensorDetailSession? _sessionValue;
  NafasClient? _client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NafasClient newClient = DataWidget.of<NafasClient>(context)!.data;
    if (newClient != _client) {
      _client = newClient;
      _sessionValue?.dispose();
      _sessionValue = null;
    }
    _sessionValue ??= _client!
        .createSensorDetailSession(widget.type, widget.device, widget.duration);
  }

  @override
  void didUpdateWidget(covariant SensorDetailScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.device != widget.device ||
        oldWidget.duration != widget.duration) {
      _sessionValue?.dispose();
      _sessionValue = _client!.createSensorDetailSession(
          widget.type, widget.device, widget.duration);
    }
  }

  @override
  void dispose() {
    _sessionValue?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionValue == null) {
      return const SizedBox();
    }
    return _sessionValue!.loading.build(
      builder: (context, future) {
        if (future != null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return DataWidget<SensorDetailSession>(
            data: _sessionValue!,
            child: widget.child,
          );
        }
      },
    );
  }
}

class DynamicText<T> extends StatelessWidget {
  final ValueListenable<T> value;
  final String Function(T value)? formatter;

  const DynamicText({
    Key? key,
    required this.value,
    required this.formatter,
  }) : super(key: key);

  String _toStringNullable(T? value) {
    if (value == null) {
      return '';
    }
    return formatter?.call(value) ?? value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: value,
      builder: (context, value, _) {
        return Text(_toStringNullable(value));
      },
    );
  }
}

extension ValueWidgetBuilder<T> on ValueListenable<T> {
  Widget build(
      {required Widget Function(BuildContext context, T value) builder}) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (context, value, _) {
        return builder(context, value);
      },
    );
  }

  Widget buildWithChild(
      {required Widget Function(BuildContext context, T value, Widget child)
          builder,
      required Widget child}) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (context, value, _) {
        return builder(context, value, child);
      },
    );
  }

  Widget text([String Function(T value)? formatter]) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (context, value, _) {
        return Text(formatter?.call(value) ?? value.toString());
      },
    );
  }
}

class UserConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, UserData? user) builder;

  const UserConsumer({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserData?>(
      valueListenable: DataWidget.of<NafasClient>(context)!.data._currentUser,
      builder: (context, value, _) {
        return builder(context, value);
      },
    );
  }
}

class SensorValueText extends StatelessWidget {
  final SensorType type;
  final String? unit;
  final String Function(double value)? formatter;

  const SensorValueText({
    Key? key,
    required this.type,
    this.unit,
    this.formatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, double>>(
      valueListenable: client._sensorValues,
      builder: (context, values, _) {
        double? value = values[type];
        if (value == null) {
          return const Text('N/A');
        }
        // return Text(value.toStringAsFixed(2) + (unit ?? ''));
        String formatted = formatter?.call(value) ?? value.toStringAsFixed(2);
        if (unit != null) {
          formatted += unit!;
        }
        return Text(
          formatted,
          maxLines: 1,
        );
      },
    );
  }
}

class TemperatureText extends StatelessWidget {
  const TemperatureText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SensorValueText(type: SensorType.temperature, unit: '°C');
  }
}

class HumidityText extends StatelessWidget {
  const HumidityText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SensorValueText(type: SensorType.humidity, unit: '%');
  }
}

class CO2Text extends StatelessWidget {
  final bool showUnit;
  const CO2Text({Key? key, this.showUnit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SensorValueText(type: SensorType.co2, unit: showUnit ? 'ppm' : null);
  }
}

class GasText extends StatelessWidget {
  final bool showUnit;
  const GasText({Key? key, this.showUnit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SensorValueText(type: SensorType.gas, unit: showUnit ? 'ppm' : null);
  }
}

class DustText extends StatelessWidget {
  final bool showUnit;
  const DustText({Key? key, this.showUnit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SensorValueText(
        type: SensorType.dust, unit: showUnit ? 'µg/m³' : null);
  }
}

class NetworkText extends StatelessWidget {
  final String onlineText;
  final String offlineText;

  const NetworkText({
    Key? key,
    this.onlineText = 'Online',
    this.offlineText = 'Offline',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataWidget.of<NafasClient>(context)!.data._currentDevice.build(
      builder: (context, value) {
        if (value == null) {
          return const Text('N/A');
        }
        return DeviceOnlineStatus(
            device: value,
            builder: (context, isOnline) {
              if (isOnline) {
                return Text(onlineText);
              } else {
                return Text(offlineText);
              }
            });
      },
    );
  }
}

class SensorConfigurations {
  final Map<SensorType, SensorConfiguration> configurations;

  const SensorConfigurations({
    required this.configurations,
  });

  SensorConfigurations.fromMap(Map<String, SensorConfiguration> configs)
      : configurations = configs.map((key, value) {
          SensorType? type = SensorType.fromId(key);
          if (type == null) {
            throw Exception('Unknown sensor type $key');
          }
          return MapEntry(type, value);
        });

  operator [](SensorType type) {
    return configurations[type] ?? type.defaultConfiguration;
  }

  operator []=(SensorType type, SensorConfiguration configuration) {
    configurations[type] = configuration;
  }
}

class UserData {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final String token;

  const UserData({
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.token,
  });
}

class NafasClient {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  final ValueNotifier<UserData?> _currentUser = ValueNotifier(null);
  final ValueNotifier<Device?> _currentDevice = ValueNotifier(null);
  final ValueNotifier<bool> _isOnline = ValueNotifier(false);
  final ValueNotifier<List<Device>> _devices = ValueNotifier([]);
  final ValueNotifier<Map<SensorType, double>> _sensorValues =
      ValueNotifier({});
  final ValueNotifier<Map<SensorType, List<DataEntry>>> _realtimeSensorHistory =
      ValueNotifier({}); // capped at 100 entries
  final ValueNotifier<List<ActivityData>> _activities = ValueNotifier([]);
  // if the activity id is lower than this value, it means that the activity is read
  final ValueNotifier<int> _readActivityId = ValueNotifier(-1);
  final ValueNotifier<Future<List<ActivityData>>?> _activityFuture =
      ValueNotifier(null);
  final ValueNotifier<int?> _activityLastId = ValueNotifier(null);
  final ValueNotifier<ActivityFilter> _currentActivityFilter =
      ValueNotifier(ActivityFilter());
  final List<SensorDetailSession> _activeSensorDetailSessions = [];
  final List<ColorSession> _activeColorSessions = [];

  final List<ActivityListSession> _activeActivityListSessions = [];
  final ValueNotifier<SensorConfigurations> _sensorConfigurations =
      ValueNotifier(SensorConfigurations(configurations: {}));
  WebSocketChannel? _socket;

  bool _disposed = false;

  Future<void> dispose() async {
    _disposed = true;
    // _socket?.close();
    _socket?.sink.close();
  }

  Future<void> signIn() async {
    await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Future<void> updateDeviceList(List<Device> devices) async {
    List<Device> newDevices = [];
    for (var device in devices) {
      Device? existingDevice = getDevice(device.id);
      if (existingDevice != null) {
        // update existing device
        existingDevice.name.value = device.name.value;
        existingDevice.isOnline.value = device.isOnline.value;
      } else {
        newDevices.add(device);
      }
    }
    // remove devices that are not in the new list
    _devices.value = _devices.value
        .where((element) => devices.any((e) => e.id == element.id))
        .toList();
    _devices.value = [..._devices.value, ...newDevices];
    // rebound
    for (var device in _devices.value) {
      device._boundClient(this);
    }
    // if current device is null or not in the list, select the first device
    if (_currentDevice.value == null ||
        !_devices.value
            .any((element) => element.id == _currentDevice.value!.id)) {
      await connect(_devices.value.firstOrNull);
    }
  }

  ValueListenable<Device?> get device => _currentDevice;
  ValueListenable<List<Device>> get devices => _devices;

  ValueNotifier<String> getDeviceName(String deviceId) {
    for (Device device in devices.value) {
      if (device.id == deviceId) {
        return device.name;
      }
    }
    return ValueNotifier(deviceId);
  }

  Device? getDevice(String id) {
    return _devices.value.where((element) => element.id == id).firstOrNull;
  }

  Future<void> changeActivityFilter(ActivityFilter activityFilter) async {
    // clear previous activities
    _activities.value = [];
    // update filter
    _currentActivityFilter.value = activityFilter;
  }

  Future<List<ActivityData>> requestActivities() {
    _activityFuture.value ??= _reqActivities().whenComplete(() {
      _activityFuture.value = null;
    });
    return _activityFuture.value!;
  }

  Future<List<ActivityData>> _reqActivities() async {
    if (_activityLastId.value == -1) {
      // no more activities
      return [];
    }
    int lastId = _activityLastId.value ?? -1;
    final activities = await request(APIRequestActivities(
      limit: 20,
      fromId: lastId,
      fromDate: -1, // get all
      toDate: -1,
      devices:
          _currentActivityFilter.value.devices?.map((e) => e.id).toList() ?? [],
      sensors:
          _currentActivityFilter.value.sensors?.map((e) => e.id).toList() ?? [],
    ));
    if (activities is APIResponseActivities) {
      // update last id
      if (activities.activities.isNotEmpty) {
        int?
            newLastId; // new last id is the smallest id (because the pagination is from latest to oldest)
        for (var activity in activities.activities.values) {
          if (newLastId == null || activity.id < newLastId) {
            newLastId = activity.id;
          }
        }
        _activityLastId.value = newLastId;
      } else {
        _activityLastId.value =
            -1; // indicate that there are no more activities
        return [];
      }
      // insert to the beginning
      // because the pagination is from latest to oldest
      _activities.value = [
        ...activities.activities.values.toList(),
        ..._activities.value,
      ];
      return activities.activities.values.toList();
    } else if (activities is APIResponseError) {
      throw Exception(activities.message);
    } else {
      throw Exception('Failed to get activities');
    }
  }

  Future<void> updateConfiguration(
      Map<SensorType, SensorConfiguration> configurations) async {
    Map<String, SensorConfiguration> parsed = {};
    for (var entry in configurations.entries) {
      parsed[entry.key.id] = entry.value;
    }
    _sensorConfigurations.value = SensorConfigurations(
      configurations: {
        ..._sensorConfigurations.value.configurations,
        ...configurations,
      },
    );
    await request(APIRequestChangeConfig(
      configurations: parsed,
    ));
  }

  Future<void> initialize() async {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account == null) {
        var user = _currentUser.value;
        if (user != null) {
          await request(APIRequestLogout(userToken: user.token));
        }
      } else {
        var auth = await account.authentication;
        var deviceName = Platform.localHostname;
        var response = await request(APIRequestLogin(
          googleAccessToken: auth.idToken!,
          deviceName: deviceName,
        ));
        if (response is APIResponseLoginSuccess) {
          _currentUser.value = UserData(
            email: account.email,
            displayName: account.displayName,
            photoUrl: account.photoUrl,
            role: response.role,
            token: response.token,
          );
        } else if (response is APIResponseError) {
          await _googleSignIn.disconnect();
          throw Exception(response.message);
        } else {
          await _googleSignIn.disconnect();
          throw Exception('Failed to login');
        }
      }
    });
    await _googleSignIn.signInSilently();
    // fetch config
    final config = await request(APIRequestConfig());
    if (config is APIResponseConfig) {
      _sensorConfigurations.value = SensorConfigurations.fromMap(
          config.configurations); // update sensor configurations
      debug('configurations: ${config.configurations}');
    } else if (config is APIResponseError) {
      throw Exception(config.message);
    } else {
      throw Exception('Failed to get config');
    }
    // request all devices
    final devices = await request(APIRequestDevices());
    if (devices is APIResponseDevices) {
      updateDeviceList(List.from(devices.devices.values));
    } else if (devices is APIResponseError) {
      throw Exception(devices.message);
    } else {
      throw Exception('Failed to get devices');
    }
    // request sensor values
    var prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device');
    Device? preferredDevice;
    if (deviceId != null) {
      preferredDevice = getDevice(deviceId);
    }
    // select first device
    preferredDevice ??= _devices.value.firstOrNull;
    // connect to websocket
    await connect(preferredDevice);
  }

  static Device offlineDevice = Device(
    id: '-1',
    name: 'No Device Detected',
    isOnline: false,
  );

  Future<void> connect(Device? selectedDevice) async {
    selectedDevice ??= offlineDevice;
    // if its the same device, don't do anything
    if (_currentDevice.value == selectedDevice) {
      return;
    }
    _realtimeSensorHistory.value = {};
    if (selectedDevice.id != '-1') {
      var sensorValues = await request(APIRequestSensorValues(
        deviceId: selectedDevice.id,
      ));
      if (sensorValues is APIResponseSensorValues) {
        _sensorValues.value = sensorValues.values.map((key, value) {
          SensorType? type = SensorType.fromId(key);
          if (type == null) {
            throw Exception('Unknown sensor type $key');
          }
          return MapEntry(type, value);
        });
        // check network value
        if ((_sensorValues.value[SensorType.network] ?? 0) == 0) {
          selectedDevice.isOnline.value = false;
          _sensorValues.value = {};
        }
      } else if (sensorValues is APIResponseError) {
        throw Exception(sensorValues.message);
      } else {
        throw Exception('Failed to get sensor values');
      }
    }

    _currentDevice.value = selectedDevice;
    if (_socket != null) {
      // _socket?.close();
      _socket?.sink.close();
      _socket = null;
    }
    // connect to websocket
    // _socket = await WebSocket.connect(
    //     'ws://$kBaseHostname:$kBasePort/device?id=${selectedDevice.id}');
    debug('connecting to websocket ${selectedDevice.id}');
    // print stack tra
    // _socket = html.WebSocket(
    //     'ws://$kBaseHostname:$kBasePort/device?id=${selectedDevice.id}');
    _socket = WebSocketChannel.connect(Uri(
      scheme: kScheme == 'https' ? 'wss' : 'ws',
      host: kBaseHostname,
      port: kBasePort ?? (kScheme == 'https' ? 443 : 80),
      path: '/device',
      queryParameters: {
        'id': selectedDevice.id,
      },
    ));
    // _socket!.onOpen.listen((event) {
    //   debug('connected to websocket');
    // });
    debug('connected to websocket');
    // _socket!.onMessage.listen((event) {
    //   final data = jsonDecode(event.data);
    //   final packet = packetFromJson(data);
    //   onPacketReceived(packet);
    // });
    _socket!.stream.listen((event) {
      final data = jsonDecode(event.toString());
      final packet = packetFromJson(data);
      onPacketReceived(packet);
    });
    // _socket?.listen((event) {
    //   final data = jsonDecode(event);
    //   final packet = packetFromJson(data);
    //   onPacketReceived(packet);
    // });
    _isOnline.value = true;
    // make it auto reconnect
    // _socket?.done.then((value) {
    //   _isOnline.value = false;
    //   // only reconnect if the device is still selected
    //   if (!_disposed && _currentDevice.value == selectedDevice) {
    //     connect(selectedDevice);
    //   }
    // });
    // _socket!.onClose.listen((event) {
    //   _isOnline.value = false;
    //   // only reconnect if the device is still selected
    //   if (!_disposed && _currentDevice.value == selectedDevice) {
    //     debug('Connection closed, reconnecting...');
    //     connect(selectedDevice);
    //   }
    // });
    _socket!.sink.done.then((value) async {
      _isOnline.value = false;
      // only reconnect if the device is still selected
      if (!_disposed && _currentDevice.value == selectedDevice) {
        debug('Connection closed, reconnecting...');
        await connect(selectedDevice);
        debug('Reconnected');
      }
    });
  }

  void onPacketReceived(Packet packet) async {
    if (packet is PacketOutboundData) {
      // update sensor detail sessions
      var sensorValues = packet.data;
      for (var entry in sensorValues.entries) {
        for (var session in _activeSensorDetailSessions) {
          if (session.sensorType.id == entry.key &&
              session.duration.value == null) {
            session.pushDataEntry(DataEntry(
              timestamp: DateTime.now().millisecondsSinceEpoch,
              value: entry.value,
            ));
          }
        }
      }
      // update sensor values
      Map<SensorType, double> values = _sensorValues.value;
      for (var entry in sensorValues.entries) {
        SensorType? type = SensorType.fromId(entry.key);
        if (type != null) {
          values[type] = entry.value;
        }
      }
      _sensorValues.value = Map.from(values); // copy to trigger update
      // update realtime sensor history
      Map<SensorType, List<DataEntry>> history = _realtimeSensorHistory.value;
      for (var entry in sensorValues.entries) {
        SensorType? type = SensorType.fromId(entry.key);
        if (type != null) {
          List<DataEntry> entries = history[type] ?? [];
          entries.add(DataEntry(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            value: entry.value,
          ));
          if (entries.length > 100) {
            entries.removeAt(0);
          }
          history[type] = entries;
        }
      }
      _realtimeSensorHistory.value =
          Map.from(history); // copy to trigger update
    } else if (packet is PacketOutboundActivity) {
      var activity = packet.activity;
      for (var session in _activeActivityListSessions) {
        if (session.filter.value.accepts(activity)) {
          session.pushActivity(activity);
        }
      }
      debug('activity: ${activity.type}');
      if (activity.type == kActivitySensorOffline) {
        Device? device = getDevice(activity.device);
        if (device != null) {
          device.isOnline.value = false;
          // clear sensor values
          if (_currentDevice.value == device) {
            _sensorValues.value = {};
          }
        } else {
          // update device list
          var response = await request(APIRequestDevices());
          if (response is APIResponseDevices) {
            updateDeviceList(List.from(response.devices.values));
          } else if (response is APIResponseError) {
            throw Exception(response.message);
          } else {
            throw Exception('Failed to get devices');
          }
        }
      } else if (activity.type == kActivitySensorOnline) {
        Device? device = getDevice(activity.device);
        if (device != null) {
          device.isOnline.value = true;
        } else {
          // update device list
          debug('Updating device list');
          var response = await request(APIRequestDevices());
          if (response is APIResponseDevices) {
            updateDeviceList(List.from(response.devices.values));
          } else if (response is APIResponseError) {
            throw Exception(response.message);
          } else {
            throw Exception('Failed to get devices');
          }
        }
      }
      // append to current activities if it passes the filter
      if (_currentActivityFilter.value.accepts(activity)) {
        _activities.value = [..._activities.value, activity];
      }
    } else if (packet is PacketConfigChangeOutbound) {
      // update sensor config sessions
      for (var entry in packet.configurations.entries) {
        SensorType? type = SensorType.fromId(entry.key);
        if (type != null) {
          _sensorConfigurations.value[type] = entry.value;
        }
      }
    } else if (packet is PacketDeviceRenameOutbound) {
      // update device name
      Device? device = getDevice(packet.deviceId);
      if (device != null) {
        device.name.value = packet.name;
      }
    } else if (packet is PacketOutboundColor) {
      // update color sessions
      for (var session in _activeColorSessions) {
        session.color.value = packet.color;
      }
    } else {
      throw Exception('Unknown packet type $packet');
    }
  }

  Future<APIData> request(APIData request) async {
    final json = request.toJson();
    var uri = Uri(
      scheme: kScheme,
      host: kBaseHostname,
      port: kBasePort,
      path: '/api',
    );
    var bodyContent = jsonEncode(json);
    final response = await http.post(
      uri,
      body: bodyContent,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return APIResponseError(
          message: 'Server returned ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body);
    return parseAPIData(data);
  }

  Future<void> sendPacket(Packet packet) async {
    final json = packet.toJson();
    _socket?.sink.add(jsonEncode(json));
    // _socket?.send(jsonEncode(json));
  }

  SensorDetailSession createSensorDetailSession(
      SensorType sensorType, Device? device, int? duration) {
    device ??= _currentDevice.value;
    if (device == null) {
      throw Exception('No device selected');
    }
    final session = SensorDetailSession(
      device: device,
      sensorType: sensorType,
      client: this,
      duration: duration,
    );
    session.init();
    _activeSensorDetailSessions.add(session);
    return session;
  }

  ColorSession createColorSession(Device? device) {
    device ??= _currentDevice.value;
    if (device == null) {
      throw Exception('No device selected');
    }
    final session = ColorSession(
      device: device,
      client: this,
    );
    session.init();
    _activeColorSessions.add(session);
    return session;
  }

  ActivityListSession createActivityListSession({
    required int limit,
    required ActivityFilter filter,
  }) {
    if (_currentDevice.value == null) {
      throw Exception('No device selected');
    }
    final session = ActivityListSession(
      limit: limit,
      filter: filter,
      client: this,
    );
    session.initialize();
    _activeActivityListSessions.add(session);
    return session;
  }

  void updateActivityReading(ActivityData activity) {
    if (activity.id > _readActivityId.value) {
      _readActivityId.value = activity.id;
    }
  }
}

class ColorSession {
  final ValueNotifier<Color> color = ValueNotifier(Colors.black);
  final ValueNotifier<bool> loading = ValueNotifier(true);
  final NafasClient client;
  final Device device;

  ColorSession({
    required this.client,
    required this.device,
  });

  void init() {
    loading.value = true;
    client.request(APIRequestColor(deviceId: device.id)).then((value) {
      if (value is APIResponseColor) {
        color.value = value.color;
      }
      loading.value = false;
    });
  }

  void changeColor(Color color) {
    client.sendPacket(PacketInboundColor(color: color));
    this.color.value = color;
  }

  void dispose() {
    client._activeColorSessions.remove(this);
  }
}

class ColorSessionBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Color color,
      void Function(Color color) setColor) builder;

  const ColorSessionBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  _ColorSessionBuilderState createState() => _ColorSessionBuilderState();
}

class _ColorSessionBuilderState extends State<ColorSessionBuilder> {
  ColorSession? session;
  NafasClient? client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NafasClient client = context.nafasClient;
    if (client != this.client) {
      this.client = client;
      session?.dispose();
      session = client.createColorSession(null);
    }
  }

  @override
  void dispose() {
    session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return session!.loading.build(
      builder: (context, isLoading) {
        if (isLoading) {
          return const SizedBox();
        }
        return session!.color.build(builder: (context, color) {
          return widget.builder(context, color, session!.changeColor);
        });
      },
    );
  }
}

class RecordedDataTimeRange {
  final int? duration;
  final String label;

  const RecordedDataTimeRange({
    required this.duration,
    required this.label,
  });
}

class ForecastTypePopupMenu extends StatelessWidget {
  final Widget Function(BuildContext context, String range) itemBuilder;

  const ForecastTypePopupMenu({
    Key? key,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return PopupMenuButton<ForecastType>(
      onSelected: (value) {
        session.forecastType.value = value;
      },
      child: session.forecastType.build(
        builder: (context, forecastType) {
          return itemBuilder(context, forecastType.display);
        },
      ),
      itemBuilder: (context) {
        return ForecastType.values.map((e) {
          return PopupMenuItem<ForecastType>(
            value: e,
            child: Text(e.display),
          );
        }).toList();
      },
    );
  }
}

class RecordedDataTimeRangePopupMenu extends StatelessWidget {
  static const List<RecordedDataTimeRange> _ranges = [
    RecordedDataTimeRange(duration: null, label: 'Realtime'),
    RecordedDataTimeRange(duration: 1000 * 60 * 60, label: 'Last 1 hour'),
    RecordedDataTimeRange(duration: 1000 * 60 * 60 * 6, label: 'Last 6 hours'),
    RecordedDataTimeRange(
        duration: 1000 * 60 * 60 * 12, label: 'Last 12 hours'),
    RecordedDataTimeRange(duration: 1000 * 60 * 60 * 24, label: 'Last 1 day'),
    RecordedDataTimeRange(
        duration: 1000 * 60 * 60 * 24 * 7, label: 'Last 1 week'),
    RecordedDataTimeRange(
        duration: 1000 * 60 * 60 * 24 * 30, label: 'Last 1 month'),
  ];

  final Widget Function(BuildContext context, String range) itemBuilder;

  const RecordedDataTimeRangePopupMenu({
    Key? key,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return PopupMenuButton<RecordedDataTimeRange>(
      onSelected: (value) {
        session.changeDuration(value.duration);
      },
      child: session.duration.build(
        builder: (context, duration) {
          RecordedDataTimeRange? selected;
          for (var range in _ranges) {
            if (range.duration == duration) {
              selected = range;
              break;
            }
          }
          return itemBuilder(context, selected?.label ?? 'Last ${duration}ms');
        },
      ),
      itemBuilder: (context) {
        return _ranges.map((e) {
          return PopupMenuItem<RecordedDataTimeRange>(
            value: e,
            child: Text(e.label),
          );
        }).toList();
      },
    );
  }
}

class ActivityListSession {
  final int limit;
  final ValueNotifier<ActivityFilter> filter;
  final NafasClient client;
  final ValueNotifier<List<ActivityData>> activities = ValueNotifier([]);
  final ValueNotifier<bool> loading = ValueNotifier(false);

  ActivityListSession({
    required this.limit,
    ActivityFilter? filter,
    required this.client,
  }) : filter = ValueNotifier(filter ?? ActivityFilter()) {
    this.filter.addListener(() {
      activities.value = [];
      initialize();
    });
  }

  void pushActivity(ActivityData activity) {
    List<ActivityData> newActivities = [activity, ...activities.value];
    if (newActivities.length > limit) {
      newActivities = newActivities.sublist(0, limit);
    }
    activities.value = newActivities;
    print('new activity: ${activity.type}');
  }

  void dispose() {
    client._activeActivityListSessions.remove(this);
  }

  Future<void> initialize() async {
    loading.value = true;
    ActivityFilter filter = this.filter.value;
    final activities = await client.request(APIRequestActivities(
      limit: limit,
      fromId: -1, // from the latest
      fromDate: filter.fromDate ?? -1,
      toDate: filter.toDate ?? -1,
      devices: filter.devices?.map((e) => e.id).toList() ?? [],
      sensors: filter.sensors?.map((e) => e.id).toList() ?? [],
    ));
    if (activities is APIResponseActivities) {
      // insert to the beginning
      this.activities.value = activities.activities.values.toList();
    }
    loading.value = false;
  }
}

class SensorDetailSession {
  // final int?
  // duration; // i.e. 1 month ago, 1 hour ago, or null for realtime (since now)
  final Device device;
  final SensorType sensorType;

  final ValueNotifier<List<DataEntry>> dataHistory = ValueNotifier([]);
  final ValueNotifier<double> average = ValueNotifier(0);
  final ValueNotifier<double> highest = ValueNotifier(0);
  final ValueNotifier<double> lowest = ValueNotifier(0);
  final ValueNotifier<int> highestTimestamp = ValueNotifier(0);
  final ValueNotifier<int> lowestTimestamp = ValueNotifier(0);
  final ValueNotifier<int?> duration = ValueNotifier(null);
  final ValueNotifier<Future<void>?> loading =
      ValueNotifier(null); // null if not loading

  final ValueNotifier<ForecastType> forecastType =
      ValueNotifier(ForecastType.nextDay);

  final NafasClient client;

  SensorDetailSession({
    required this.client,
    required this.device,
    required this.sensorType,
    required int? duration,
  }) {
    this.duration.value = duration;
  }

  void changeDuration(int? duration) {
    this.duration.value = duration;
    dataHistory.value = [];
    init();
  }

  void init() {
    loading.value = _init().whenComplete(() {
      loading.value = null;
    });
  }

  void dispose() {
    client._activeSensorDetailSessions.remove(this);
  }

  void pushDataEntry(DataEntry entry) {
    List<DataEntry> dataHistory = [...this.dataHistory.value, entry];
    // update average
    double sum = 0;
    for (var entry in dataHistory) {
      sum += entry.value;
    }
    average.value = sum / dataHistory.length;
    // update highest
    double? highest;
    int? highestTimestamp;
    for (var entry in dataHistory) {
      if (highest == null || entry.value > highest) {
        highest = entry.value;
        highestTimestamp = entry.timestamp;
      }
    }
    this.highest.value = highest ?? 0;
    // update highest timestamp
    this.highestTimestamp.value =
        highestTimestamp ?? DateTime.now().millisecondsSinceEpoch;
    // update lowest
    double? lowest;
    int? lowestTimestamp;
    for (var entry in dataHistory) {
      if (lowest == null || entry.value < lowest) {
        lowest = entry.value;
        lowestTimestamp = entry.timestamp;
      }
    }
    this.lowest.value = lowest ?? 0;
    // update lowest timestamp
    this.lowestTimestamp.value =
        lowestTimestamp ?? DateTime.now().millisecondsSinceEpoch;
    // update data history
    this.dataHistory.value = dataHistory;
  }

  Future<void> _init() async {
    // get previous data
    if (duration.value != null) {
      int fromDate = DateTime.now()
          .subtract(Duration(milliseconds: duration.value!))
          .millisecondsSinceEpoch;
      int toDate = DateTime.now().millisecondsSinceEpoch;
      final data = await client.request(APIRequestData(
        fromDate: fromDate,
        toDate: toDate,
        deviceId: device.id,
        sensorId: sensorType.id,
      ));
      if (data is APIResponseData) {
        dataHistory.value = data.data
            .map((e) => DataEntry(
                  timestamp: e.timestamp,
                  value: e.value,
                ))
            .toList();
        lowest.value = data.lowest;
        lowestTimestamp.value = data.lowestWhen;
        highest.value = data.highest;
        highestTimestamp.value = data.highestWhen;
        average.value = data.average;
      }
    } else {
      List<DataEntry>? cachedRealtimeData =
          client._realtimeSensorHistory.value[sensorType];
      if (cachedRealtimeData != null) {
        dataHistory.value = cachedRealtimeData;
        // calculate average
        double sum = 0;
        for (var entry in cachedRealtimeData) {
          sum += entry.value;
        }
        average.value = sum / cachedRealtimeData.length;
        // calculate highest
        double? highest;
        int? highestTimestamp;
        for (var entry in cachedRealtimeData) {
          if (highest == null || entry.value > highest) {
            highest = entry.value;
            highestTimestamp = entry.timestamp;
          }
        }
        this.highest.value = highest ?? 0;
        // update highest timestamp
        this.highestTimestamp.value =
            highestTimestamp ?? DateTime.now().millisecondsSinceEpoch;
        // update lowest
        double? lowest;
        int? lowestTimestamp;
        for (var entry in cachedRealtimeData) {
          if (lowest == null || entry.value < lowest) {
            lowest = entry.value;
            lowestTimestamp = entry.timestamp;
          }
        }
        this.lowest.value = lowest ?? 0;
        // update lowest timestamp
        this.lowestTimestamp.value =
            lowestTimestamp ?? DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
}

Packet packetFromJson(Map<String, dynamic> data) {
  switch (data['type']) {
    case kPacketOutboundData:
      return PacketOutboundData.fromJson(data);
    case kPacketOutboundActivity:
      return PacketOutboundActivity.fromJson(data);
    case kPacketOutboundConfig:
      return PacketConfigChangeOutbound.fromJson(data);
    case kPacketOutboundDeviceRename:
      return PacketDeviceRenameOutbound.fromJson(data);
    case kPacketInboundColor:
      return PacketInboundColor.fromJson(data);
    case kPacketOutboundColor:
      return PacketOutboundColor.fromJson(data);
    default:
      throw Exception('Unknown packet type: ${data['type']}');
  }
}

APIData parseAPIData(Map<String, dynamic> data) {
  switch (data['type']) {
    case kAPIResponseError:
      return APIResponseError.fromJson(data);
    case kAPIResponseLoginSuccess:
      return APIResponseLoginSuccess.fromJson(data);
    case kAPIResponseLogoutSuccess:
      return APIResponseLogoutSuccess.fromJson(data);
    case kAPIResponseConfig:
      return APIResponseConfig.fromJson(data);
    case kAPIResponseDevices:
      return APIResponseDevices.fromJson(data);
    case kAPIResponseActivities:
      return APIResponseActivities.fromJson(data);
    case kAPIResponseData:
      return APIResponseData.fromJson(data);
    case kAPIResponseForecast:
      return APIResponseForecast.fromJson(data);
    case kAPIResponseSuccess:
      return APIResponseSuccess.fromJson(data);
    case kAPIResponseSensorValues:
      return APIResponseSensorValues.fromJson(data);
    case kAPIResponseColor:
      return APIResponseColor.fromJson(data);
    default:
      throw Exception('Unknown API response type: ${data['type']}');
  }
}

class Packet {
  final String type;
  Packet.fromJson(Map<String, dynamic> data) : type = data['type'];
  Packet({required this.type});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}

class PacketInboundColor extends Packet {
  final Color color;

  PacketInboundColor.fromJson(Map<String, dynamic> data)
      : color = APIResponseColor.fromMap(data['color']),
        super.fromJson(data);

  PacketInboundColor({required this.color}) : super(type: kPacketInboundColor);

  @override
  Map<String, dynamic> toJson() {
    HSVColor hsv = HSVColor.fromColor(color);
    return {
      ...super.toJson(),
      'color': {
        'hue': (hsv.hue / 360 * 255).toInt(),
        'saturation': (hsv.saturation * 255).toInt(),
        'value': (hsv.value * 255).toInt(),
      }
    };
  }
}

class PacketOutboundColor extends Packet {
  final Color color;

  PacketOutboundColor.fromJson(Map<String, dynamic> data)
      : color = APIResponseColor.fromMap(data['color']),
        super.fromJson(data);

  PacketOutboundColor({required this.color})
      : super(type: kPacketOutboundColor);

  @override
  Map<String, dynamic> toJson() {
    HSVColor hsv = HSVColor.fromColor(color);
    return {
      ...super.toJson(),
      'color': {
        'hue': (hsv.hue / 360 * 255).toInt(),
        'saturation': (hsv.saturation * 255).toInt(),
        'value': (hsv.value * 255).toInt(),
      }
    };
  }
}

class PacketOutboundData extends Packet {
  final Map<String, double> data; // {sensorId: value}

  PacketOutboundData.fromJson(Map<String, dynamic> data)
      :
        // remap from Map<String, dynamic> to Map<String, double>
        data = (data['data'] as Map)
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
        super.fromJson(data);
  PacketOutboundData({required this.data}) : super(type: kPacketOutboundData);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'data': data,
    };
  }
}

class PacketOutboundActivity extends Packet {
  final ActivityData activity;

  PacketOutboundActivity.fromJson(Map<String, dynamic> data)
      : activity = ActivityData(
          id: -1, // PATCH: id is not used in the protocol
          type: data['activity']['type'],
          timestamp: (data['activity']['timestamp'] as num).toInt(),
          device: data['activity']['device'],
          sensor: data['activity']['sensor'],
          value: (data['activity']['value'] as num).toDouble(),
        ),
        super.fromJson(data);

  PacketOutboundActivity({required this.activity})
      : super(type: kPacketOutboundActivity);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'activity': {
        'type': activity.type,
        'timestamp': activity.timestamp,
        'device': activity.device,
        'sensor': activity.sensor,
        'value': activity.value,
      },
    };
  }
}

class SensorConfiguration {
  final double min;
  final double max;

  const SensorConfiguration({
    required this.min,
    required this.max,
  });
}

class PacketConfigChangeOutbound extends Packet {
  final Map<String, SensorConfiguration> configurations;

  PacketConfigChangeOutbound.fromJson(Map<String, dynamic> data)
      : configurations =
            (data['configurations'] as Map).map((key, value) => MapEntry(
                key,
                SensorConfiguration(
                  min: (value['min'] as num).toDouble(),
                  max: (value['max'] as num).toDouble(),
                ))),
        super.fromJson(data);

  PacketConfigChangeOutbound({required this.configurations})
      : super(type: kPacketOutboundConfig);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'configurations': configurations.map((key, value) => MapEntry(
            key,
            {
              'min': value.min,
              'max': value.max,
            },
          ))
    };
  }
}

class PacketDeviceRenameOutbound extends Packet {
  final String deviceId;
  final String name;

  PacketDeviceRenameOutbound.fromJson(Map<String, dynamic> data)
      : deviceId = data['deviceId'],
        name = data['name'],
        super.fromJson(data);

  PacketDeviceRenameOutbound({required this.deviceId, required this.name})
      : super(type: kPacketOutboundDeviceRename);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceId': deviceId,
      'name': name,
    };
  }
}

class APIData {
  final String type;
  APIData.fromJson(Map<String, dynamic> data) : type = data['type'];
  APIData({required this.type});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}

class APIRequestChangeConfig extends APIData {
  final Map<String, SensorConfiguration> configurations;

  APIRequestChangeConfig.fromJson(Map<String, dynamic> data)
      : configurations =
            (data['configurations'] as Map).map((key, value) => MapEntry(
                key,
                SensorConfiguration(
                  min: (value['min'] as num).toDouble(),
                  max: (value['max'] as num).toDouble(),
                ))),
        super.fromJson(data);

  APIRequestChangeConfig({required this.configurations})
      : super(type: kAPIRequestChangeConfig);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'configurations': configurations.map((key, value) => MapEntry(
            key,
            {
              'min': value.min,
              'max': value.max,
            },
          ))
    };
  }
}

class APIResponseSuccess extends APIData {
  APIResponseSuccess.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  APIResponseSuccess() : super(type: kAPIResponseSuccess);
}

class APIRequestBeepDevice extends APIData {
  final String deviceId;
  final String userToken;

  APIRequestBeepDevice.fromJson(Map<String, dynamic> data)
      : deviceId = data['deviceId'],
        userToken = data['userToken'],
        super.fromJson(data);

  APIRequestBeepDevice({required this.deviceId, required this.userToken})
      : super(type: kAPIRequestBeepDevice);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceId': deviceId,
      'userToken': userToken,
    };
  }
}

class APIRequestRenameDevice extends APIData {
  final String userToken;
  final String deviceId;
  final String deviceName;

  APIRequestRenameDevice.fromJson(Map<String, dynamic> data)
      : userToken = data['userToken'],
        deviceId = data['deviceId'],
        deviceName = data['deviceName'],
        super.fromJson(data);

  APIRequestRenameDevice(
      {required this.userToken,
      required this.deviceId,
      required this.deviceName})
      : super(type: kAPIRequestRenameDevice);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userToken': userToken,
      'deviceId': deviceId,
      'deviceName': deviceName,
    };
  }
}

class APIResponseError extends APIData {
  final String message;

  APIResponseError.fromJson(Map<String, dynamic> data)
      : message = data['message'],
        super.fromJson(data);

  APIResponseError({required this.message}) : super(type: kAPIResponseError);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'message': message,
    };
  }
}

class APIRequestLogin extends APIData {
  final String deviceName;
  final String googleAccessToken;

  APIRequestLogin.fromJson(Map<String, dynamic> data)
      : deviceName = data['deviceName'],
        googleAccessToken = data['googleAccessToken'],
        super.fromJson(data);

  APIRequestLogin({required this.deviceName, required this.googleAccessToken})
      : super(type: kAPIRequestLogin);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceName': deviceName,
      'googleAccessToken': googleAccessToken,
    };
  }
}

class APIRequestLogout extends APIData {
  final String userToken;

  APIRequestLogout.fromJson(Map<String, dynamic> data)
      : userToken = data['userToken'],
        super.fromJson(data);

  APIRequestLogout({required this.userToken}) : super(type: kAPIRequestLogout);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userToken': userToken,
    };
  }
}

class APIRequestColor extends APIData {
  final String deviceId;

  APIRequestColor.fromJson(Map<String, dynamic> data)
      : deviceId = data['deviceId'],
        super.fromJson(data);

  APIRequestColor({required this.deviceId}) : super(type: kAPIRequestColor);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceId': deviceId,
    };
  }
}

class APIResponseColor extends APIData {
  final Color color;

  static Color fromHSV(double hue, double saturation, double value) {
    hue = hue.clamp(0, 360);
    saturation = saturation.clamp(0, 1);
    value = value.clamp(0, 1);
    return HSVColor.fromAHSV(1, hue, saturation, value).toColor();
  }

  static Color fromMap(Map<String, dynamic> data) {
    int hue = (data['hue'] as num).toInt();
    int saturation = (data['saturation'] as num).toInt();
    int value = (data['value'] as num).toInt();
    double transformedHue = hue / 255 * 360;
    double transformedSaturation = saturation / 255;
    double transformedValue = value / 255;
    return fromHSV(transformedHue, transformedSaturation, transformedValue);
  }

  APIResponseColor.fromJson(Map<String, dynamic> data)
      : color = fromMap(data['color'] as Map<String, dynamic>),
        super.fromJson(data);
}

class APIRequestConfig extends APIData {
  APIRequestConfig.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  APIRequestConfig() : super(type: kAPIRequestConfig);
}

class APIRequestDevices extends APIData {
  APIRequestDevices.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  APIRequestDevices() : super(type: kAPIRequestDevices);
}

class APIRequestActivities extends APIData {
  final int limit;
  final int fromId;
  final int fromDate;
  final int toDate;
  final List<String> devices;
  final List<String> sensors;

  APIRequestActivities.fromJson(Map<String, dynamic> data)
      : fromId = data['fromId'],
        limit = data['limit'],
        fromDate = data['fromDate'],
        toDate = data['toDate'],
        devices = data['devices'],
        sensors = data['sensors'],
        super.fromJson(data);

  APIRequestActivities(
      {required this.fromId,
      required this.limit,
      required this.fromDate,
      required this.toDate,
      required this.devices,
      required this.sensors})
      : super(type: kAPIRequestActivities);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fromId': fromId,
      'limit': limit,
      'fromDate': fromDate,
      'toDate': toDate,
      'devices': devices,
      'sensors': sensors,
    };
  }
}

class APIRequestData extends APIData {
  final int fromDate;
  final int toDate;
  final String deviceId;
  final String sensorId;

  APIRequestData.fromJson(Map<String, dynamic> data)
      : fromDate = data['fromDate'],
        toDate = data['toDate'],
        deviceId = data['deviceId'],
        sensorId = data['sensorId'],
        super.fromJson(data);

  APIRequestData(
      {required this.fromDate,
      required this.toDate,
      required this.deviceId,
      required this.sensorId})
      : super(type: kAPIRequestData);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fromDate': fromDate,
      'toDate': toDate,
      'deviceId': deviceId,
      'sensorId': sensorId,
    };
  }
}

class APIResponseLoginSuccess extends APIData {
  final String token;
  final String role;

  APIResponseLoginSuccess.fromJson(Map<String, dynamic> data)
      : token = data['token'],
        role = data['role'],
        super.fromJson(data);

  APIResponseLoginSuccess({required this.token, required this.role})
      : super(type: kAPIResponseLoginSuccess);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'token': token,
      'role': role,
    };
  }
}

class APIResponseLogoutSuccess extends APIData {
  APIResponseLogoutSuccess.fromJson(Map<String, dynamic> data)
      : super.fromJson(data);

  APIResponseLogoutSuccess() : super(type: kAPIResponseLogoutSuccess);
}

class APIResponseConfig extends APIData {
  final Map<String, SensorConfiguration> configurations;

  APIResponseConfig.fromJson(Map<String, dynamic> data)
      : configurations =
            (data['configurations'] as Map).map((key, value) => MapEntry(
                key,
                SensorConfiguration(
                  min: (value['min'] as num).toDouble(),
                  max: (value['max'] as num).toDouble(),
                ))),
        super.fromJson(data);

  APIResponseConfig({required this.configurations})
      : super(type: kAPIResponseConfig);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'configurations': configurations.map((key, value) => MapEntry(
            key,
            {
              'min': value.min,
              'max': value.max,
            },
          ))
    };
  }
}

class APIResponseDevices extends APIData {
  final Map<String, Device> devices;

  APIResponseDevices.fromJson(Map<String, dynamic> data)
      : devices = (data['devices'] as Map).map((key, value) {
          String k = key.toString();
          return MapEntry(
              key.toString(),
              Device(
                id: k, // PATCH: key is the device id (this doesn't exist in the protocol)
                name: value['name'],
                isOnline: value['isOnline'],
              ));
        }),
        super.fromJson(data);

  APIResponseDevices({required this.devices})
      : super(type: kAPIResponseDevices);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'devices': devices.map((key, value) => MapEntry(
            key,
            {
              'name': value.name,
              'isOnline': value.isOnline,
            },
          ))
    };
  }
}

class APIResponseActivities extends APIData {
  final Map<int, ActivityData> activities;

  APIResponseActivities.fromJson(Map<String, dynamic> data)
      : activities = (data['activities'] as Map).map((key, value) => MapEntry(
            int.tryParse(key.toString()) ?? -1,
            ActivityData(
              id: int.tryParse(key.toString()) ?? -1,
              type: value['type'],
              timestamp: value['timestamp'],
              device: value['device'],
              sensor: value['sensor'],
              value: double.tryParse(value['value'].toString()) ?? 0,
            ))),
        super.fromJson(data);

  APIResponseActivities({required this.activities})
      : super(type: kAPIResponseActivities);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'activities': activities.map((key, value) => MapEntry(
            key,
            {
              'type': value.type,
              'timestamp': value.timestamp,
              'device': value.device,
              'sensor': value.sensor,
              'value': value.value,
            },
          ))
    };
  }
}

class APIResponseData extends APIData {
  final List<DataEntry> data;
  final double average;
  final double highest;
  final double lowest;
  final int highestWhen;
  final int lowestWhen;

  APIResponseData.fromJson(Map<String, dynamic> data)
      : data = (data['data'] as List).map((e) {
          return DataEntry(
            timestamp: (e['timestamp'] as num).toInt(),
            value: (e['value'] as num).toDouble(),
          );
        }).toList(),
        average = (data['average'] as num?)?.toDouble() ?? 0,
        highest = (data['highest'] as num?)?.toDouble() ?? 0,
        lowest = (data['lowest'] as num?)?.toDouble() ?? 0,
        highestWhen = (data['highestWhen'] as num?)?.toInt() ?? -1,
        lowestWhen = (data['lowestWhen'] as num?)?.toInt() ?? -1,
        super.fromJson(data);

  APIResponseData(
      {required this.data,
      required this.average,
      required this.highest,
      required this.lowest,
      required this.highestWhen,
      required this.lowestWhen})
      : super(type: kAPIResponseData);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'data': data.map((e) => {
            'timestamp': e.timestamp,
            'value': e.value,
          }),
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'highestWhen': highestWhen,
      'lowestWhen': lowestWhen,
    };
  }
}

class APIRequestForecast extends APIData {
  static const int forecastUntilNextDay = 1000 * 60 * 60 * 24;
  static const int forecastUntilNextWeek = forecastUntilNextDay * 7;
  static const int forecastUntilNextMonth = forecastUntilNextDay * 30;
  final String deviceId;
  final String sensorId;
  final int forecastUntil;

  APIRequestForecast.fromJson(Map<String, dynamic> data)
      : deviceId = data['deviceId'],
        sensorId = data['sensorId'],
        forecastUntil = data['forecastUntil'],
        super.fromJson(data);

  APIRequestForecast(
      {required this.deviceId,
      required this.sensorId,
      required this.forecastUntil})
      : super(type: kAPIRequestForecast);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceId': deviceId,
      'sensorId': sensorId,
      'forecastUntil': forecastUntil,
    };
  }
}

class APIResponseForecast extends APIData {
  final List<DataEntry> forecast;

  APIResponseForecast.fromJson(Map<String, dynamic> data)
      : forecast = (data['forecast'] as List)
            .map((e) => DataEntry(
                  timestamp: (e['timestamp'] as num).toInt(),
                  value: (e['value'] as num).toDouble(),
                ))
            .toList(),
        super.fromJson(data);

  APIResponseForecast({required this.forecast})
      : super(type: kAPIResponseForecast);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'forecast': forecast.map((e) => {
            'timestamp': e.timestamp,
            'value': e.value,
          }),
    };
  }
}

class APIRequestSensorValues extends APIData {
  final String deviceId;

  APIRequestSensorValues.fromJson(Map<String, dynamic> data)
      : deviceId = data['deviceId'],
        super.fromJson(data);

  APIRequestSensorValues({required this.deviceId})
      : super(type: kAPIRequestSensorValues);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deviceId': deviceId,
    };
  }
}

class APIResponseSensorValues extends APIData {
  final Map<String, double> values;

  APIResponseSensorValues.fromJson(Map<String, dynamic> data)
      : values = (data['values'] as Map).map((key, value) => MapEntry(
              key,
              (value as num).toDouble(),
            )),
        super.fromJson(data);

  APIResponseSensorValues({required this.values})
      : super(type: kAPIResponseSensorValues);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'values': values,
    };
  }
}

extension StyledText on Widget {
  Widget withStyle(TextStyle style) {
    return DefaultTextStyle(style: style, child: this);
  }
}

class Device {
  final String id;
  final ValueNotifier<String> name = ValueNotifier('');

  final ValueNotifier<bool> isOnline = ValueNotifier(false);

  late NafasClient client;

  Device({
    required this.id,
    required String? name,
    required bool isOnline,
  }) {
    this.name.value = name ?? id;
    this.isOnline.value = isOnline;
  }

  void _boundClient(NafasClient client) {
    this.client = client;
  }

  Future<void> beep() async {
    await client.sendPacket(PacketOutboundActivity(
      activity: ActivityData(
        id: -1, // PATCH: id is not used in the protocol
        type: 'beep',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        device: id,
        sensor: '',
        value: 0,
      ),
    ));
  }

  Future<void> rename(String name) async {
    await client.request(APIRequestRenameDevice(
        userToken: client._currentUser.value?.token ?? '',
        deviceId: id,
        deviceName: name));
    // no need to update the name here, it will be updated by the server
  }
}

class CurrentDeviceText extends StatelessWidget {
  const CurrentDeviceText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<Device?>(
      valueListenable: client._currentDevice,
      builder: (context, device, _) {
        if (device == null) {
          return const Text('No device selected');
        }
        return Text(device.name.value);
      },
    );
  }
}

class DeviceListBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, List<Device> devices) builder;

  const DeviceListBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<List<Device>>(
      valueListenable: client._devices,
      builder: (context, devices, _) {
        return builder(context, devices);
      },
    );
  }
}

class RenameDeviceButton extends StatelessWidget {
  final Device device;

  const RenameDeviceButton({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        String? newName = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Rename device'),
              content: TextField(
                decoration: const InputDecoration(
                  labelText: 'New name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Rename'),
                ),
              ],
            );
          },
        );
        if (newName != null) {
          await device.rename(newName);
        }
      },
      icon: const Icon(Icons.edit),
    );
  }
}

class SensorValuesBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Map<SensorType, double> data)
      builder;

  const SensorValuesBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, double>>(
      valueListenable: client._sensorValues,
      builder: (context, data, _) {
        return builder(context, data);
      },
    );
  }
}

class SensorSessionChart extends StatefulWidget {
  final Border? border;
  final Color? titleColor;
  final Color? gridColor;
  final Color? lineColor;
  final Color? outlineDotColor;
  final Color? dotColor;
  final Color? contentColor;

  const SensorSessionChart({
    Key? key,
    this.border,
    this.titleColor,
    this.gridColor,
    this.lineColor,
    this.outlineDotColor,
    this.dotColor,
    this.contentColor,
  }) : super(key: key);

  @override
  State<SensorSessionChart> createState() => _SensorSessionChartState();
}

String formatNum(double d, int digits) {
  if (d.toInt() == d) {
    return d.toString();
  }
  return d.toStringAsFixed(2);
}

class _SensorSessionChartState extends State<SensorSessionChart> {
  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    int? duration = session.duration.value;
    return GestureDetector(
      // TODO: Scrollable
      child: ValueListenableBuilder<List<DataEntry>>(
        valueListenable: session.dataHistory,
        builder: (context, data, _) {
          double? lowestTimestamp;
          double? highestTimestamp;
          if (data.isNotEmpty) {
            lowestTimestamp = data.first.timestamp.toDouble();
            highestTimestamp = data.last.timestamp.toDouble();
          }
          double maxTime = 1000 * 60;
          return LineChart(
            LineChartData(
              clipData: FlClipData.all(),
              minX: session.duration.value != null ||
                      lowestTimestamp == null ||
                      highestTimestamp == null
                  ? null
                  : ((highestTimestamp) - maxTime),
              maxX: session.duration.value != null ||
                      highestTimestamp == null ||
                      lowestTimestamp == null
                  ? null
                  : (highestTimestamp),
              // minX: (now - maxX) - (1000 * 60 * 60).toDouble(),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    dashArray: [5, 5],
                    color: widget.gridColor ?? Colors.grey,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    dashArray: [5, 5],
                    color: widget.gridColor ?? Colors.grey,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatNum(value, 2),
                        style: TextStyle(
                          color: widget.titleColor,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 70,
                    getTitlesWidget: (value, meta) {
                      DateTime date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      int hour = date.hour;
                      int minute = date.minute;
                      int second = date.second;
                      String hourString = hour.toString().padLeft(2, '0');
                      String minuteString = minute.toString().padLeft(2, '0');
                      String secondString = second.toString().padLeft(2, '0');
                      String timeString =
                          '$hourString:$minuteString:$secondString';
                      return RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          timeString,
                          style: TextStyle(
                            color: widget.titleColor,
                          ),
                          // vertical
                        ),
                      );
                    },
                    showTitles: true,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: widget.border,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .map((e) => FlSpot(
                            e.timestamp.toDouble(),
                            e.value,
                          ))
                      .toList(),
                  // isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.contentColor ?? Colors.blue.withOpacity(0.3),
                  ),
                  dotData: FlDotData(
                    show: duration == null,
                    getDotPainter: (spot, val, barData, i) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: widget.dotColor ?? Colors.blue,
                        strokeWidth: 2,
                        strokeColor: widget.outlineDotColor ?? Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum ForecastType {
  nextDay(1000 * 60 * 60 * 24, 'Next day'),
  nextWeek(1000 * 60 * 60 * 24 * 7, 'Next week');
  // nextMonth(1000 * 60 * 60 * 24 * 30, 'Next month');

  final int duration;
  final String display;
  const ForecastType(this.duration, this.display);
}

class SensorForecastingChart extends StatefulWidget {
  final Device? device;
  final SensorType sensor;
  final Border? border;
  final Color? titleColor;
  final Color? gridColor;
  final Color? lineColor;
  final Color? outlineDotColor;
  final Color? dotColor;
  final Color? contentColor;
  final int? duration;

  const SensorForecastingChart({
    Key? key,
    required this.sensor,
    this.device,
    this.border,
    this.titleColor,
    this.gridColor,
    this.lineColor,
    this.outlineDotColor,
    this.dotColor,
    this.contentColor,
    this.duration,
  }) : super(key: key);

  @override
  State<SensorForecastingChart> createState() => _SensorForecastingChartState();
}

class _SensorForecastingChartState extends State<SensorForecastingChart> {
  late Future<List<DataEntry>> _future;

  SensorDetailSession? _session;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session?.forecastType.removeListener(_onChangeType);
    _session = DataWidget.of<SensorDetailSession>(context)?.data;
    _session?.forecastType.addListener(_onChangeType);
    _future = _fetchData();
  }

  void _onChangeType() {
    setState(() {
      _future = _fetchData();
    });
  }

  Future<List<DataEntry>> _fetchData() async {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    var response = await client.request(APIRequestForecast(
      deviceId: widget.device?.id ?? client._currentDevice.value!.id,
      sensorId: widget.sensor.id,
      forecastUntil: _session?.forecastType.value.duration ??
          widget.duration ??
          (1000 * 60 * 60 * 24),
    ));
    if (response is APIResponseForecast) {
      return response.forecast;
    } else if (response is APIResponseError) {
      throw Exception(response.message);
    }
    return [];
  }

  @override
  void didUpdateWidget(covariant SensorForecastingChart oldWidget) {
    if (oldWidget.sensor != widget.sensor ||
        oldWidget.device != widget.device ||
        oldWidget.duration != widget.duration) {
      _future = _fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _session?.forecastType.removeListener(_onChangeType);
    _future = Future.value([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LineChart(
            LineChartData(
              clipData: FlClipData.all(),
              // minX: (now - maxX) - (1000 * 60 * 60).toDouble(),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    dashArray: [5, 5],
                    color: widget.gridColor ?? Colors.grey,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    dashArray: [5, 5],
                    color: widget.gridColor ?? Colors.grey,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatNum(value, 2),
                        style: TextStyle(
                          color: widget.titleColor,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 70,
                    getTitlesWidget: (value, meta) {
                      DateTime date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      int hour = date.hour;
                      int minute = date.minute;
                      int second = date.second;
                      String hourString = hour.toString().padLeft(2, '0');
                      String minuteString = minute.toString().padLeft(2, '0');
                      String secondString = second.toString().padLeft(2, '0');
                      String timeString =
                          '$hourString:$minuteString:$secondString';
                      return RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          timeString,
                          style: TextStyle(
                            color: widget.titleColor,
                          ),
                          // vertical
                        ),
                      );
                    },
                    showTitles: true,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: widget.border,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: snapshot.data!
                      .map((e) => FlSpot(
                            e.timestamp.toDouble(),
                            e.value,
                          ))
                      .toList(),
                  // isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.contentColor ?? Colors.blue.withOpacity(0.3),
                  ),
                  dotData: FlDotData(
                    show: false,
                    getDotPainter: (spot, val, barData, i) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: widget.dotColor ?? Colors.blue,
                        strokeWidth: 2,
                        strokeColor: widget.outlineDotColor ?? Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class SensorAverageValueText extends StatelessWidget {
  final SensorType type;

  const SensorAverageValueText({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return ValueListenableBuilder<double>(
      valueListenable: session.average,
      builder: (context, value, _) {
        return Text(value.toStringAsFixed(2));
      },
    );
  }
}

class SensorHighestValueText extends StatelessWidget {
  final SensorType type;

  const SensorHighestValueText({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return ValueListenableBuilder<double>(
      valueListenable: session.highest,
      builder: (context, value, _) {
        return Text(value.toStringAsFixed(2));
      },
    );
  }
}

class SensorLowestValueText extends StatelessWidget {
  final SensorType type;

  const SensorLowestValueText({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return ValueListenableBuilder<double>(
      valueListenable: session.lowest,
      builder: (context, value, _) {
        return Text(value.toStringAsFixed(2));
      },
    );
  }
}

class SensorHighestTimeText extends StatelessWidget {
  final SensorType type;

  const SensorHighestTimeText({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return ValueListenableBuilder<double>(
      valueListenable: session.highest,
      builder: (context, value, _) {
        return Text(
          session.highestTimestamp.value == -1
              ? 'N/A'
              : formatDate(session.highestTimestamp.value),
        );
      },
    );
  }
}

class SensorLowestTimeText extends StatelessWidget {
  final SensorType type;

  const SensorLowestTimeText({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SensorDetailSession session =
        DataWidget.of<SensorDetailSession>(context)!.data;
    return ValueListenableBuilder<double>(
      valueListenable: session.lowest,
      builder: (context, value, _) {
        return Text(
          session.lowestTimestamp.value == -1
              ? 'N/A'
              : formatDate(session.lowestTimestamp.value),
        );
      },
    );
  }
}

class ActivityFilterScope extends StatefulWidget {
  final Widget child;
  final ActivityFilter? initialFilter;

  const ActivityFilterScope({
    Key? key,
    required this.child,
    this.initialFilter,
  }) : super(key: key);

  @override
  State<ActivityFilterScope> createState() => ActivityFilterScopeState();
}

class ActivityFilterScopeState extends State<ActivityFilterScope> {
  late ValueNotifier<ActivityFilter> _filter;
  @override
  void initState() {
    super.initState();
    _filter = ValueNotifier(widget.initialFilter ?? ActivityFilter());
  }

  @override
  Widget build(BuildContext context) {
    return DataWidget<ActivityFilterScopeState>(
      data: this,
      child: widget.child,
    );
  }
}

// use to change the selected device on the client app
class DeviceButton extends StatelessWidget {
  final Device device;
  final Widget child;
  final VoidCallback? onTap;

  const DeviceButton({
    Key? key,
    required this.device,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return GestureDetector(
      onTap: () {
        client.connect(device).onError((error, stackTrace) {
          print(error);
          print(stackTrace);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        });
        if (onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}

class SignInButton extends StatelessWidget {
  final Widget child;

  const SignInButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return GestureDetector(
      onTap: () async {
        await client.signIn();
      },
      child: child,
    );
  }
}

class SignOutButton extends StatelessWidget {
  final Widget child;

  const SignOutButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return GestureDetector(
      onTap: () async {
        await client.signOut();
      },
      child: child,
    );
  }
}

class ConfigurationScope extends StatefulWidget {
  final Widget child;
  final Map<SensorType, SensorConfiguration>? initialConfigurations;

  const ConfigurationScope({
    Key? key,
    required this.child,
    this.initialConfigurations,
  }) : super(key: key);

  @override
  State<ConfigurationScope> createState() => ConfigurationScopeState();
}

class ConfigurationScopeState extends State<ConfigurationScope> {
  late ValueNotifier<Map<SensorType, SensorConfiguration>> _configurations;
  @override
  void initState() {
    super.initState();
    _configurations = ValueNotifier(widget.initialConfigurations ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return DataWidget<ConfigurationScopeState>(
      data: this,
      child: widget.child,
    );
  }
}

class TemperatureThresholdSlider extends StatelessWidget {
  const TemperatureThresholdSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, SensorConfiguration>>(
      valueListenable: configScope._configurations,
      builder: (context, configurations, _) {
        // using RangeSlider to select min and max temperature
        return RangeSlider(
          values: RangeValues(
            configurations[SensorType.temperature]?.min ?? 0,
            configurations[SensorType.temperature]?.max ?? 0,
          ),
          onChanged: (values) {
            configScope._configurations.value = {
              ...configurations,
              SensorType.temperature: SensorConfiguration(
                min: values.start,
                max: values.end,
              ),
            };
          },
          min: 0,
          max: 50,
          divisions: 50,
          labels: RangeLabels(
            configurations[SensorType.temperature]?.min.toString() ?? '0',
            configurations[SensorType.temperature]?.max.toString() ?? '0',
          ),
        );
      },
    );
  }
}

class HumidityThresholdSlider extends StatelessWidget {
  const HumidityThresholdSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, SensorConfiguration>>(
      valueListenable: configScope._configurations,
      builder: (context, configurations, _) {
        // using RangeSlider to select min and max humidity
        return RangeSlider(
          values: RangeValues(
            configurations[SensorType.humidity]?.min ?? 0,
            configurations[SensorType.humidity]?.max ?? 0,
          ),
          onChanged: (values) {
            configScope._configurations.value = {
              ...configurations,
              SensorType.humidity: SensorConfiguration(
                min: values.start,
                max: values.end,
              ),
            };
          },
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            configurations[SensorType.humidity]?.min.toString() ?? '0',
            configurations[SensorType.humidity]?.max.toString() ?? '0',
          ),
        );
      },
    );
  }
}

class GasThresholdSlider extends StatelessWidget {
  const GasThresholdSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, SensorConfiguration>>(
      valueListenable: configScope._configurations,
      builder: (context, configurations, _) {
        // using RangeSlider to select min and max gas
        return RangeSlider(
          values: RangeValues(
            configurations[SensorType.gas]?.min ?? 0,
            configurations[SensorType.gas]?.max ?? 0,
          ),
          onChanged: (values) {
            configScope._configurations.value = {
              ...configurations,
              SensorType.gas: SensorConfiguration(
                min: values.start,
                max: values.end,
              ),
            };
          },
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            configurations[SensorType.gas]?.min.toString() ?? '0',
            configurations[SensorType.gas]?.max.toString() ?? '0',
          ),
        );
      },
    );
  }
}

class DustThresholdSlider extends StatelessWidget {
  const DustThresholdSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, SensorConfiguration>>(
      valueListenable: configScope._configurations,
      builder: (context, configurations, _) {
        // using RangeSlider to select min and max dust
        return RangeSlider(
          values: RangeValues(
            configurations[SensorType.dust]?.min ?? 0,
            configurations[SensorType.dust]?.max ?? 0,
          ),
          onChanged: (values) {
            configScope._configurations.value = {
              ...configurations,
              SensorType.dust: SensorConfiguration(
                min: values.start,
                max: values.end,
              ),
            };
          },
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            configurations[SensorType.dust]?.min.toString() ?? '0',
            configurations[SensorType.dust]?.max.toString() ?? '0',
          ),
        );
      },
    );
  }
}

class CO2ThresholdSlider extends StatelessWidget {
  const CO2ThresholdSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    return ValueListenableBuilder<Map<SensorType, SensorConfiguration>>(
      valueListenable: configScope._configurations,
      builder: (context, configurations, _) {
        // using RangeSlider to select min and max CO2
        return RangeSlider(
          values: RangeValues(
            configurations[SensorType.co2]?.min ?? 0,
            configurations[SensorType.co2]?.max ?? 0,
          ),
          onChanged: (values) {
            configScope._configurations.value = {
              ...configurations,
              SensorType.co2: SensorConfiguration(
                min: values.start,
                max: values.end,
              ),
            };
          },
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            configurations[SensorType.co2]?.min.toString() ?? '0',
            configurations[SensorType.co2]?.max.toString() ?? '0',
          ),
        );
      },
    );
  }
}

class ApplyConfigurationButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const ApplyConfigurationButton({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigurationScopeState configScope =
        DataWidget.of<ConfigurationScopeState>(context)!.data;
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return GestureDetector(
      onTap: () {
        onPressed?.call();
        client
            .updateConfiguration(configScope._configurations.value)
            .onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        });
      },
      child: child,
    );
  }
}

class FilterSelectDevicesButton extends StatelessWidget {
  final Widget child;

  const FilterSelectDevicesButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityFilterScopeState filterScope =
        DataWidget.of<ActivityFilterScopeState>(context)!.data;
    return GestureDetector(
      onTap: () async {
        List<String>? selectedDevices = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select devices'),
              content: DeviceListBuilder(
                builder: (context, devices) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      Device device = devices[index];
                      return ValueListenableBuilder<ActivityFilter>(
                        valueListenable: filterScope._filter,
                        builder: (context, filter, _) {
                          return CheckboxListTile(
                            title: Text(device.name.value),
                            value: filter.devices?.contains(device) ?? false,
                            onChanged: (value) {
                              if (value == true) {
                                filterScope._filter.value =
                                    filter.copyWith(devices: [
                                  if (filter.devices != null)
                                    ...filter.devices!,
                                  device,
                                ]);
                              } else {
                                filterScope._filter.value =
                                    filter.copyWith(devices: [
                                  if (filter.devices != null)
                                    ...filter.devices!
                                      ..removeWhere(
                                          (element) => element == device),
                                ]);
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (selectedDevices != null) {}
      },
      child: child,
    );
  }
}

class SelectFromDateButton extends StatelessWidget {
  final Widget child;

  const SelectFromDateButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityFilterScopeState filterScope =
        DataWidget.of<ActivityFilterScopeState>(context)!.data;
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          filterScope._filter.value = filterScope._filter.value
              .copyWith(fromDate: selectedDate.millisecondsSinceEpoch);
        }
      },
      child: child,
    );
  }
}

class SelectToDateButton extends StatelessWidget {
  final Widget child;

  const SelectToDateButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityFilterScopeState filterScope =
        DataWidget.of<ActivityFilterScopeState>(context)!.data;
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          filterScope._filter.value = filterScope._filter.value
              .copyWith(toDate: selectedDate.millisecondsSinceEpoch);
        }
      },
      child: child,
    );
  }
}

class SelectSensorTypesButton extends StatelessWidget {
  final Widget child;

  const SelectSensorTypesButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityFilterScopeState filterScope =
        DataWidget.of<ActivityFilterScopeState>(context)!.data;
    return GestureDetector(
      onTap: () async {
        List<SensorType>? selectedSensors = await showDialog<List<SensorType>>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select sensors'),
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: SensorType.values.length,
                itemBuilder: (context, index) {
                  SensorType sensor = SensorType.values[index];
                  return ValueListenableBuilder<ActivityFilter>(
                    valueListenable: filterScope._filter,
                    builder: (context, filter, _) {
                      return CheckboxListTile(
                        title: Text(sensor.name),
                        value: filter.sensors?.contains(sensor) ?? false,
                        onChanged: (value) {
                          if (value == true) {
                            filterScope._filter.value =
                                filter.copyWith(sensors: [
                              if (filter.sensors != null) ...filter.sensors!,
                              sensor,
                            ]);
                          } else {
                            filterScope._filter.value =
                                filter.copyWith(sensors: [
                              if (filter.sensors != null)
                                ...filter.sensors!
                                  ..removeWhere((element) => element == sensor),
                            ]);
                          }
                        },
                      );
                    },
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (selectedSensors != null) {}
      },
      child: child,
    );
  }
}

class DeviceBeepButton extends StatelessWidget {
  final Device device;
  final Widget child;

  const DeviceBeepButton({
    Key? key,
    required this.device,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await device.beep();
      },
      child: child,
    );
  }
}

class DeviceOnlineStatus extends StatelessWidget {
  final Device device;
  final Widget Function(BuildContext context, bool isOnline) builder;

  const DeviceOnlineStatus({
    Key? key,
    required this.device,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: device.isOnline,
      builder: (context, isOnline, _) {
        return builder(context, isOnline);
      },
    );
  }
}

// wrap button using this to open Activity details page
class SelectActivityButton extends StatefulWidget {
  final ActivityData activity;
  final Widget child;
  final Widget Function(BuildContext context, ActivityData activity)
      pageBuilder;

  const SelectActivityButton({
    Key? key,
    required this.child,
    required this.pageBuilder,
    required this.activity,
  }) : super(key: key);

  @override
  State<SelectActivityButton> createState() => _SelectActivityButtonState();
}

class ActivityReadMarker extends StatelessWidget {
  final ActivityData activity;

  final Widget child;

  const ActivityReadMarker({
    Key? key,
    required this.activity,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<int>(
      valueListenable: client._readActivityId,
      builder: (context, lastReadActivity, _) {
        // if (activity.id > lastReadActivity) {
        //   return const Icon(Icons.circle, color: Colors.red);
        // }
        // return const SizedBox();
        if (activity.id <= lastReadActivity) return child;
        return Badge(
          backgroundColor: Colors.red,
          child: child,
        );
      },
    );
  }
}

class _SelectActivityButtonState extends State<SelectActivityButton> {
  NafasClient? client;
  ActivityData? activity;

  @override
  void initState() {
    super.initState();
    activity = widget.activity;
  }

  @override
  void didUpdateWidget(covariant SelectActivityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    activity = widget.activity;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    client = DataWidget.of<NafasClient>(context)!.data;
  }

  @override
  void dispose() {
    if (client != null && activity != null) {
      client!.updateActivityReading(activity!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return widget.pageBuilder(context, widget.activity);
            },
          ),
        );
      },
      child: widget.child,
    );
  }
}

class BackButton extends StatelessWidget {
  final Widget child;

  const BackButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: child,
    );
  }
}

class ApplyFilterButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const ApplyFilterButton({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ActivityListSession? session =
            DataWidget.of<ActivityListSession>(context)?.data;
        ActivityFilterScopeState filterScope =
            DataWidget.of<ActivityFilterScopeState>(context)!.data;
        if (session != null) {
          session.filter.value = filterScope._filter.value;
        } else {
          NafasClient client = DataWidget.of<NafasClient>(context)!.data;
          client.changeActivityFilter(filterScope._filter.value);
        }
        onPressed?.call();
      },
      child: child,
    );
  }
}

class UsernameText extends StatelessWidget {
  const UsernameText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<UserData?>(
      valueListenable: client._currentUser,
      builder: (context, username, _) {
        if (username == null) {
          return const Text('Not signed in');
        }
        return Text(
          username.displayName ?? username.email,
          maxLines: 1,
        );
      },
    );
  }
}

class UserBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, UserData? user) builder;

  const UserBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NafasClient client = DataWidget.of<NafasClient>(context)!.data;
    return ValueListenableBuilder<UserData?>(
      valueListenable: client._currentUser,
      builder: (context, user, _) {
        return builder(context, user);
      },
    );
  }
}

class UserEmailText extends StatelessWidget {
  const UserEmailText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserBuilder(builder: (context, user) {
      if (user == null) {
        return const Text('Not signed in');
      }
      return Text(user.email);
    });
  }
}

class UserPhoto extends StatelessWidget {
  const UserPhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if not signed in, show default avatar
    // if signed in but has no photo, show their display name or email initial
    // if signed in and has photo, show their photo
    return UserBuilder(builder: (context, user) {
      if (user == null) {
        return const CircleAvatar(
          child: Icon(Icons.person),
        );
      }
      var photo = user.photoUrl;
      if (photo == null) {
        String text = user.displayName ?? user.email;
        String initialBuilder = text.split(' ').map((e) => e[0]).join();
        if (initialBuilder.length < 2) {
          if (text.length < 2) {
            initialBuilder = text;
          } else {
            initialBuilder = text.substring(0, 2);
            // title case
            initialBuilder = initialBuilder[0].toUpperCase() +
                initialBuilder.substring(1).toLowerCase();
          }
        } else {
          // max 2 characters
          if (initialBuilder.length > 2) {
            initialBuilder = initialBuilder.substring(0, 2);
          }
          initialBuilder = initialBuilder.toUpperCase();
        }
        return CircleAvatar(
          child: Text(initialBuilder),
        );
      }
      return CircleAvatar(
        backgroundImage: NetworkImage(photo),
      );
    });
  }
}

String formatDate(int timestamp) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  // dd/MM/yyyy HH:mm
  String day = date.day.toString().padLeft(2, '0');
  String month = date.month.toString().padLeft(2, '0');
  String year = date.year.toString();
  String hour = date.hour.toString().padLeft(2, '0');
  String minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
