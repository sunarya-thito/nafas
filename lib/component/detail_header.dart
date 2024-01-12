import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

class DetailHeader extends StatelessWidget {
  final Widget title;
  final Widget header;

  final Widget? trailing;

  const DetailHeader({
    Key? key,
    required this.title,
    required this.header,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.secondaryTextColor,
                ),
                child: header,
              ),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 20,
                  color: context.theme.primaryTextColor,
                ),
                child: title,
              ),
            ],
          )),
          if (trailing != null)
            IconTheme(
                data: IconThemeData(color: context.theme.secondaryTextColor),
                child: trailing!),
        ],
      ),
    );
  }
}
