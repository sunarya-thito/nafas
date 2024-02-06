import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/theme.dart';

class ActivityTile extends StatelessWidget {
  final Widget? icon;
  final Widget header;
  final Widget content;
  final Widget? trailing;
  const ActivityTile(
      {Key? key,
      this.icon,
      required this.header,
      required this.content,
      this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPaneInkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (icon != null)
                IconTheme(
                  data: IconThemeData(
                    color: context.theme.secondaryTextColor,
                    size: 32,
                  ),
                  child: icon!,
                ),
              if (icon != null)
                const SizedBox(
                  width: 12,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTextStyle(
                      style: context.theme.secondaryText(
                        fontSize: 12,
                      ),
                      child: header,
                    ),
                    DefaultTextStyle(
                      style: context.theme
                          .text(fontSize: 16, overflow: TextOverflow.clip),
                      child: content,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                const SizedBox(
                  width: 12,
                ),
              if (trailing != null) trailing!
            ],
          ),
        ),
      ),
    );
  }
}
