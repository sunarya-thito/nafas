import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/nafas_client_app.dart';
import 'package:nafas/theme.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DeviceListBuilder(
      builder: (context, devices) {
        return ListView.separated(
          itemCount: devices.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
          itemBuilder: (context, index) {
            var device = devices[index];
            return DeviceButton(
                device: device,
                onTap: () {
                  context.pop();
                },
                child: GlassPaneInkWell(
                    child: DeviceOnlineStatus(
                        device: device,
                        builder: (context, isOnline) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //       if (isOnline) {
                                      // return Text('Online').withStyle(TextStyle(
                                      // color: context.theme.secondaryTextColor,
                                      // ));
                                      // } else {
                                      // return Text('Offline').withStyle(TextStyle(
                                      // color: context.theme.secondaryTextColor,
                                      // ));
                                      // }
                                      if (isOnline)
                                        Text('Online').withStyle(TextStyle(
                                          fontSize: 12,
                                          color:
                                              context.theme.secondaryTextColor,
                                        ))
                                      else
                                        Text('Offline').withStyle(TextStyle(
                                          fontSize: 12,
                                          color:
                                              context.theme.secondaryTextColor,
                                        )),
                                      device.name.text().withStyle(
                                            TextStyle(
                                              fontSize: 24,
                                              color: context
                                                  .theme.primaryTextColor,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  color: context.theme.secondaryTextColor,
                                  itemBuilder: (context) {
                                    return [];
                                  },
                                ),
                              ],
                            ),
                          );
                        })));
          },
        );
      },
    );
  }
}
