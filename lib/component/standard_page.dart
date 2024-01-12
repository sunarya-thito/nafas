import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas/component/background_blob.dart';
import 'package:nafas/component/bottom_nav_bar.dart';

class StandardPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StandardPage({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  @override
  _StandardPageState createState() => _StandardPageState();
}

class _StandardPageState extends State<StandardPage> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBlob(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        bottomNavigationBar: Container(
          height: 58 + 18 * 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: BottomNavBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onTap: (value) {
              if (widget.navigationShell.currentIndex != value) {
                widget.navigationShell.goBranch(value);
              } else {
                // go to root of current branch
                var ctx = widget.navigationShell.shellRouteContext.navigatorKey
                    .currentContext;
                Navigator.of(ctx!).popUntil((route) => route.isFirst);
              }
            },
          ),
        ),
        body: ShaderMask(
          shaderCallback: (bounds) {
            // padding is 64 from bottom where content starts to fade
            return LinearGradient(
              colors: const [
                Colors.white,
                Colors.white,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [
                0,
                (bounds.height - (64 + 24 * 2)) / bounds.height,
                (bounds.height - (64 - 9 * 2)) / bounds.height,
                1,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 52),
            child: widget.navigationShell,
          ),
        ),
      ),
    );
  }
}
