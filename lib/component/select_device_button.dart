import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/component/standard_sub_page.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

import '../pages/device_list_page.dart';

class SelectDeviceButton extends StatelessWidget {
  const SelectDeviceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPaneInkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return StandardSubPage(
              header: Text('Select Device'),
              child: DeviceListPage(),
            );
          }));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Device').withStyle(TextStyle(
                    fontSize: 12,
                    color: context.theme.secondaryTextColor,
                  )),
                  CurrentDeviceText().withStyle(TextStyle(
                    fontSize: 24,
                    color: context.theme.primaryTextColor,
                  )),
                ],
              )),
              Icon(
                Icons.expand_more,
                color: context.theme.secondaryTextColor,
              )
            ],
          ),
        ));
  }
}
