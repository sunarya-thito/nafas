import 'package:flutter/material.dart';
import 'package:nafas/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: context.theme.surfaceColor,
        border: Border.all(color: context.theme.surfaceBorderColor, width: 2),
        borderRadius: BorderRadius.circular(42),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: IconTheme(
        data: IconThemeData(
          color: context.theme.secondaryTextColor,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            var width = constraints.maxWidth;
            return Stack(
              children: [
                AnimatedPositioned(
                  top: 0,
                  left: width / 3 * selectedIndex,
                  bottom: 0,
                  right: width / 3 * (2 - selectedIndex),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: context.theme.selectedSurfaceColor,
                      border: Border.all(
                        color: context.theme.selectedSurfaceBorderColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(0),
                          behavior: HitTestBehavior.translucent,
                          child: Center(
                            child: Icon(Icons.house_outlined),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(1),
                          behavior: HitTestBehavior.translucent,
                          child: Center(
                            child: Icon(Icons.query_stats),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(2),
                          behavior: HitTestBehavior.translucent,
                          child: Center(
                            child: Icon(Icons.notes),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
