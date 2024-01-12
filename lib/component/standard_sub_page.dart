import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/theme.dart';

class StandardSubPage extends StatelessWidget {
  final Widget? title;
  final Widget header;
  final Widget child;

  final VoidCallback? onBack;

  const StandardSubPage({
    Key? key,
    this.title,
    required this.header,
    required this.child,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VoidCallback? onBack = this.onBack;
    if (onBack == null && context.canPop()) {
      onBack = () {
        context.pop();
      };
    }
    return Container(
      padding: EdgeInsets.only(top: 32 + 14, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  color: context.theme.secondaryTextColor,
                  icon: Icon(Icons.arrow_back_ios_new),
                ),
              if (onBack != null)
                const SizedBox(
                  width: 18,
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    DefaultTextStyle(
                      style: context.theme.secondaryText(
                        fontSize: 12,
                      ),
                      child: title!,
                    ),
                  DefaultTextStyle(
                    style: context.theme.text(
                      fontSize: 20,
                    ),
                    child: header,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
