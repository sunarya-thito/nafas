import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/theme.dart';

class SensorTile extends StatelessWidget {
  final Widget icon;
  final Widget header;
  final Widget content;
  final VoidCallback? action;
  const SensorTile({
    Key? key,
    required this.icon,
    required this.header,
    required this.content,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPaneInkWell(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: context.theme.secondaryTextColor,
                size: 72,
              ),
              child: icon,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: context.theme.secondaryText(
                      fontSize: 12,
                    ),
                    child: header,
                  ),
                  DefaultTextStyle(
                    style: context.theme.text(
                      fontSize: 24,
                    ),
                    child: content,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            IconButton(
              onPressed: action,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: context.theme.secondaryTextColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
