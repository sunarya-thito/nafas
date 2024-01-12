import 'package:flutter/material.dart';
import 'package:nafas/component/glass_pane.dart';
import 'package:nafas/theme.dart';

class Dropdown extends StatelessWidget {
  final Widget header;
  final Widget content;
  final VoidCallback? action;
  const Dropdown(
      {Key? key, required this.header, required this.content, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPaneInkWell(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: context.theme.secondaryText(fontSize: 12),
                    child: header,
                  ),
                  DefaultTextStyle(
                    style: context.theme.text(fontSize: 20),
                    child: content,
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: action,
              icon: Icon(
                Icons.expand_more,
                color: context.theme.secondaryTextColor,
                size: 32,
              ),
            )
          ],
        ),
      ),
    );
  }
}
