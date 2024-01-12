import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

class IconBadge extends StatelessWidget {
  final bool show;
  final int count;
  final bool showNumber;
  final bool forceShowNumber;
  final Color? color;
  final TextStyle? countStyle;
  final Widget content;
  final AlignmentGeometry alignment;
  const IconBadge(
      {Key? key,
      this.show = true,
      this.count = 1,
      this.showNumber = true,
      this.forceShowNumber = false,
      this.color,
      required this.content,
      this.countStyle,
      this.alignment = Alignment.topRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (show && count > 0) {
      Widget badge;
      if (showNumber && (count > 1 || forceShowNumber)) {
        badge = Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color ?? context.theme.badgeColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: countStyle ?? context.theme.text(fontSize: 8),
          ),
        );
      } else {
        badge = Container(
          decoration: BoxDecoration(
            color: color ?? context.theme.badgeColor,
            shape: BoxShape.circle,
          ),
          width: 8,
          height: 8,
        );
      }
      return Stack(
        children: [
          content,
          Positioned.fill(
            child: Align(
              alignment: alignment,
              child: badge,
            ),
          ),
        ],
      );
    }
    return content;
  }
}
