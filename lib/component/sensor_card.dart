import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/theme.dart';

class SensorCard extends StatelessWidget {
  final Widget icon;
  final Widget shortName;
  final Widget value;
  final Widget? unit;
  final VoidCallback? onTap;

  const SensorCard({
    Key? key,
    required this.icon,
    required this.shortName,
    required this.value,
    this.unit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: GlassPaneInkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              bottom: -40,
              left: -40,
              width: 120,
              height: 120,
              child: IconTheme(
                data: IconThemeData(
                  color: context.theme.secondaryTextColor,
                  size: 120,
                ),
                child: icon,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Spacer(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: context.theme.secondaryText(
                              fontSize: 12,
                              overflow: TextOverflow.fade,
                            ),
                            child: shortName,
                          ),
                          DefaultTextStyle(
                            style: context.theme.text(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.fade,
                            ),
                            child: FittedBox(
                              child: value,
                            ),
                          ),
                          if (unit != null)
                            DefaultTextStyle(
                              style: context.theme.secondaryText(
                                fontSize: 12,
                              ),
                              child: unit!,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
