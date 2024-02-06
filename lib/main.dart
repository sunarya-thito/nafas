import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/app_data.dart';
import 'package:nafas/component/rebuilder.dart';
import 'package:nafas/component/standard_page.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/pages/activity_details_page.dart';
import 'package:nafas/pages/home_page.dart';
import 'package:nafas/pages/log_page.dart';
import 'package:nafas/pages/status_detail_page.dart';
import 'package:nafas/pages/status_page.dart';
import 'package:nafas/pages/web_page.dart';

void main() {
  if (!kDebugMode) {
    kScheme = html.window.location.protocol;
    if (kScheme == 'http:') {
      kScheme = 'http';
    } else {
      kScheme = 'https';
    }
    kBaseHostname = html.window.location.hostname ?? 'localhost';
    kBasePort = int.tryParse(html.window.location.port);
  }
  print('Initializing with hostname: $kBaseHostname and port: $kBasePort');
  GoRouter.optionURLReflectsImperativeAPIs = true;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NafasApp());
}

class NafasApp extends StatefulWidget {
  const NafasApp({Key? key}) : super(key: key);

  @override
  State<NafasApp> createState() => _NafasAppState();
}

const kHomePage = 'home';
const kStatusPage = 'status';
const kStatusDetailPage = 'detail';
const kActivityLogPage = 'log';
const kActivityFilterPage = 'filter';
const kActivityDetailPage = 'activity_detail';
const kLogPage = 'log';
const kTestPage = 'test';
const kSelectDevicePage = 'select_device';

class _NafasAppState extends State<NafasApp> {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _navigatorKeys = {
    kHomePage: GlobalKey<NavigatorState>(),
    kStatusPage: GlobalKey<NavigatorState>(),
    kLogPage: GlobalKey<NavigatorState>(),
    // kTestPage: GlobalKey<NavigatorState>(),
  };

  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Rebuilder(
                child: StandardPage(navigationShell: navigationShell));
            // return StandardPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: _navigatorKeys[kHomePage]!,
              routes: [
                GoRoute(
                  path: '/',
                  name: kHomePage,
                  builder: (context, state) => HomePage(),
                ),
              ],
            ),
            // test
            // StatefulShellBranch(
            //   navigatorKey: _navigatorKeys[kTestPage]!,
            //   routes: [
            //     GoRoute(
            //       path: '/test',
            //       name: kTestPage,
            //       builder: (context, state) => TestPage(),
            //     ),
            //   ],
            // ),
            StatefulShellBranch(
              navigatorKey: _navigatorKeys[kStatusPage]!,
              routes: [
                GoRoute(
                  path: '/status',
                  name: kStatusPage,
                  builder: (context, state) => StatusPage(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: kStatusDetailPage,
                      builder: (context, state) {
                        // SensorType? type = context.data.getSensorType(
                        //     state.uri.queryParameters['sensor'] ?? '');
                        SensorType? type = SensorType.values.where((element) {
                          return element.name ==
                              state.uri.queryParameters['sensor'];
                        }).firstOrNull;
                        if (type != null) {
                          return StatusDetailPage(
                            type: type,
                            showForecast: type.showForecast,
                          );
                          // SensorDevice? device = context.selectedDevice;
                          // if (device != null) {
                          //   return StandardSubPage(
                          //     header: Text(type.name),
                          //     title: DynamicText(value: device.name),
                          //     child:
                          //         StatusDetailPage(device: device, type: type),
                          //   );
                          // }
                        }
                        return const StatusPage();
                      },
                    )
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _navigatorKeys[kLogPage]!,
              routes: [
                GoRoute(
                    path: '/log',
                    name: kLogPage,
                    builder: (context, state) => LogPage(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: kActivityDetailPage,
                        builder: (context, state) {
                          String? activityId =
                              state.uri.queryParameters['activityId'];
                          if (activityId != null) {
                            // Future<Activity?> activity = context.data
                            //     .getActivity(int.tryParse(activityId) ?? -1);
                            return ActivityDetailsPage();
                          }
                          return LogPage();
                        },
                      ),
                    ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return NafasClientApp(
              child: NafasData(
                child: Builder(
                  builder: (context) {
                    return MaterialApp(
                      theme: NafasDataWidget.of(context)!.themeMode ==
                              ThemeMode.dark
                          ? ThemeData.dark(
                              useMaterial3: true,
                            )
                          : ThemeData.light(
                              useMaterial3: true,
                            ),
                      debugShowCheckedModeBanner: false,
                      title: 'Nafas',
                      home: WebPage(),
                    );
                  },
                ),
              ),
            );
          }
          return buildNafasClientApp();
        },
      );
    }
    return buildNafasClientApp();
  }

  NafasClientApp buildNafasClientApp() {
    return NafasClientApp(
      child: NafasData(
        child: Builder(builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Nafas',
            // theme: ThemeData.dark(
            //   useMaterial3: true,
            // ),
            theme: NafasDataWidget.of(context)!.themeMode == ThemeMode.dark
                ? ThemeData.dark(
                    useMaterial3: true,
                  )
                : ThemeData.light(
                    useMaterial3: true,
                  ),
            routerConfig: _router,
          );
        }),
      ),
    );
  }
}
