import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

class PageSection extends StatelessWidget {
  final Widget title;
  final Widget? action;
  final Widget? child;

  const PageSection({
    Key? key,
    required this.title,
    this.action,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: context.theme.secondaryText(
                    fontSize: 20,
                  ),
                  child: title,
                ),
              ),
              if (action != null)
                IconTheme(
                  data: IconThemeData(
                    size: 20,
                    color: context.theme.secondaryTextColor,
                  ),
                  child: action!,
                ),
            ],
          ),
          if (child != null) const SizedBox(height: 8),
          if (child != null) child!,
        ],
      ),
    );
  }
}
