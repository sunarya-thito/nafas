import 'package:flutter/material.dart';
import 'package:nafas/component/standard_sub_page.dart';
import 'package:nafas/component/summary_activity_list.dart';
import 'package:nafas/nafas_client_app.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    return StandardSubPage(
      header: Text('Activity Log'),
      child: SummaryActivityList(
          filter: ActivityFilter(), showDeviceName: true, limit: 100),
    );
  }
}
