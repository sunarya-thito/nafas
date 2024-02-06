import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

class GlassPane extends StatelessWidget {
  final Widget child;

  const GlassPane({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: context.theme.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: context.theme.surfaceBorderColor.withOpacity(0.9),
          width: 2,
        ),
      ),
      child: Material(
        child: child,
        color: Colors.transparent,
      ),
    );
  }
}

class GlassPaneInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const GlassPaneInkWell({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          splashColor: context.theme.secondaryTextColor.withOpacity(0.5),
          child: child,
        ),
      ),
    );
  }
}
