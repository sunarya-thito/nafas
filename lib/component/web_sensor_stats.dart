import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

class WebSensorStats extends StatefulWidget {
  final Widget title;
  final SensorType sensorType;

  const WebSensorStats({
    Key? key,
    required this.title,
    required this.sensorType,
  }) : super(key: key);

  @override
  _WebSensorStatsState createState() => _WebSensorStatsState();
}

enum WebSensorStatsType {
  summary,
  realtime,
  previousDay,
  // previousWeek,
  forecastNextDay,
  // forecastNextWeek,
}

class TrimmedTween extends Animatable<double> {
  final double min;
  final double max;

  TrimmedTween({
    required this.min,
    required this.max,
  });

  @override
  double transform(double t) {
    if (t < min) {
      return 0;
    }
    if (t > max) {
      return 1;
    }
    return (t - min) / (max - min);
  }
}

class _WebSensorStatsState extends State<WebSensorStats> {
  WebSensorStatsType _type = WebSensorStatsType.summary;
  bool _locked = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    scheduleNext();
  }

  void scheduleNext() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 10), () {
      if (!_locked) {
        switchType();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void switchType() {
    int ordinal = _type.index + 1;
    if (ordinal >= WebSensorStatsType.values.length) {
      ordinal = 0;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _type = WebSensorStatsType.values[ordinal];
    });
    scheduleNext();
  }

  Widget buildStats() {
    if (_type == WebSensorStatsType.realtime) {
      return context.nafasClient.device.build(
        builder: (context, selectedDevice) {
          if (selectedDevice == null) {
            return Container();
          }
          return SensorDetailScope(
              type: widget.sensorType,
              device: selectedDevice,
              child: SensorSessionChart(
                border: Border.all(
                  color: context.theme.surfaceBorderColor,
                ),
                titleColor: context.theme.secondaryTextColor,
                gridColor: context.theme.surfaceBorderColor,
              ));
        },
      );
    } else if (_type == WebSensorStatsType.previousDay) {
      return context.nafasClient.device.build(
        builder: (context, selectedDevice) {
          if (selectedDevice == null) {
            return Container();
          }
          return SensorDetailScope(
              type: widget.sensorType,
              device: selectedDevice,
              duration: 1000 * 60 * 60 * 24,
              child: SensorSessionChart(
                border: Border.all(
                  color: context.theme.surfaceBorderColor,
                ),
                titleColor: context.theme.secondaryTextColor,
                gridColor: context.theme.surfaceBorderColor,
              ));
        },
      );
      // } else if (_type == WebSensorStatsType.previousWeek) {
      //   return context.nafasClient.device.build(
      //     builder: (context, selectedDevice) {
      //       if (selectedDevice == null) {
      //         return Container();
      //       }
      //       return SensorDetailScope(
      //           type: widget.sensorType,
      //           device: selectedDevice,
      //           duration: 1000 * 60 * 60 * 24 * 7,
      //           child: SensorSessionChart(
      //             border: Border.all(
      //               color: context.theme.surfaceBorderColor,
      //             ),
      //             titleColor: context.theme.secondaryTextColor,
      //             gridColor: context.theme.surfaceBorderColor,
      //           ));
      //     },
      //   );
    } else if (_type == WebSensorStatsType.forecastNextDay) {
      return context.nafasClient.device.build(
        builder: (context, selectedDevice) {
          if (selectedDevice == null) {
            return Container();
          }
          return SensorForecastingChart(
            sensor: widget.sensorType,
            device: selectedDevice,
            duration: 1000 * 60 * 60 * 24,
            border: Border.all(
              color: context.theme.surfaceBorderColor,
            ),
            titleColor: context.theme.secondaryTextColor,
            gridColor: context.theme.surfaceBorderColor,
          );
        },
      );
      // } else if (_type == WebSensorStatsType.forecastNextWeek) {
      //   return context.nafasClient.device.build(
      //     builder: (context, selectedDevice) {
      //       if (selectedDevice == null) {
      //         return Container();
      //       }
      //       return SensorForecastingChart(
      //         sensor: widget.sensorType,
      //         device: selectedDevice,
      //         duration: 1000 * 60 * 60 * 24 * 7,
      //         border: Border.all(
      //           color: context.theme.surfaceBorderColor,
      //         ),
      //         titleColor: context.theme.secondaryTextColor,
      //         gridColor: context.theme.surfaceBorderColor,
      //       );
      //     },
      //   );
    }
    return context.nafasClient.device.build(
      builder: (context, selectedDevice) {
        if (selectedDevice == null) {
          return Container();
        }
        return SensorDetailScope(
          type: widget.sensorType,
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildSection(
                          Text('Current'),
                          SensorValueText(type: widget.sensorType),
                          buildUnit(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // avg
                      Expanded(
                        child: buildSection(
                          Text('Average'),
                          SensorAverageValueText(type: widget.sensorType),
                          buildUnit(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildSection(
                          Text('Min'),
                          SensorLowestValueText(type: widget.sensorType),
                          buildUnit(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: buildSection(
                          Text('Max'),
                          SensorHighestValueText(type: widget.sensorType),
                          buildUnit(),
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
  }

  Widget buildUnit() {
    if (widget.sensorType == SensorType.temperature) {
      return Text('°C');
    }
    if (widget.sensorType == SensorType.humidity) {
      return Text('%');
    }
    if (widget.sensorType == SensorType.co2) {
      return Text('ppm');
    }
    if (widget.sensorType == SensorType.dust) {
      return Text('μg/m³');
    }
    if (widget.sensorType == SensorType.gas) {
      return Text('ppm');
    }
    return Container();
  }

  Widget buildSection(Widget title, Widget child, Widget unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            children: [
              DefaultTextStyle(
                style: context.theme.text(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                child: child,
              ),
              const SizedBox(width: 4),
              DefaultTextStyle(
                style: context.theme.secondaryText(
                  fontSize: 20,
                ),
                child: unit,
              ),
            ],
          ),
        ),
        DefaultTextStyle(
          style: context.theme.secondaryText(
            fontSize: 16,
          ),
          child: title,
        ),
      ],
    );
  }

  Widget buildSubtitle() {
    if (_type == WebSensorStatsType.realtime) {
      return Text('Realtime');
    }
    if (_type == WebSensorStatsType.previousDay) {
      return Text('Previous Day');
    }
    // if (_type == WebSensorStatsType.previousWeek) {
    //   return Text('Previous Week');
    // }
    if (_type == WebSensorStatsType.forecastNextDay) {
      return Text('Forecast Next Day');
    }
    // if (_type == WebSensorStatsType.forecastNextWeek) {
    //   return Text('Forecast Next Week');
    // }
    if (_type == WebSensorStatsType.summary) {
      return Text('Summary');
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPaneInkWell(
      onTap: () {
        switchType();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          // crossFade
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey(_type),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: context.theme.secondaryText(fontSize: 12),
                          child: buildSubtitle(),
                        ),
                        DefaultTextStyle(
                          style: context.theme.text(
                            fontSize: 20,
                          ),
                          child: widget.title,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    color: context.theme.secondaryTextColor,
                    onPressed: () {
                      setState(() {
                        _locked = !_locked;
                      });
                      if (!_locked) {
                        scheduleNext();
                      }
                    },
                    icon: _locked ? Icon(Icons.lock) : Icon(Icons.lock_open),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IgnorePointer(child: buildStats()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
