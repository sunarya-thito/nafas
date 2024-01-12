import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:nafas/app_data.dart';
import 'package:nafas/theme.dart';

import '../nafas_client_app.dart';

class Greeting extends StatelessWidget {
  const Greeting({Key? key}) : super(key: key);

  String get greetingMessage {
    // based on current time, return a greeting message
    // Good Morning, Good Afternoon, Good Evening, Good Night
    var now = DateTime.now();
    // 3-11 Good Morning
    // 11-17 Good Afternoon
    // 17-21 Good Evening
    // 21-3 Good Night
    if (now.hour >= 3 && now.hour < 11) {
      return 'Good Morning';
    } else if (now.hour >= 11 && now.hour < 17) {
      return 'Good Afternoon';
    } else if (now.hour >= 17 && now.hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingMessage,
                  style: context.theme.secondaryText(fontSize: 16),
                ),
                UserConsumer(
                  builder: (context, user) {
                    if (user != null) {
                      return Text(
                        user.displayName ?? user.email,
                      );
                    }
                    return SizedBox(
                      height: 32,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -20,
                            bottom: -20,
                            left: 0,
                            right: 0,
                            child: DefaultTextStyle(
                              style: context.theme.text(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                pause: Duration.zero,
                                animatedTexts: [
                                  RotateAnimatedText(
                                    'Welcome to Nafas!',
                                    textAlign: TextAlign.start,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  RotateAnimatedText(
                                    'Please sign in',
                                    textAlign: TextAlign.start,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  RotateAnimatedText(
                                    'Air Quality Control System',
                                    textAlign: TextAlign.start,
                                    alignment: Alignment.centerLeft,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return Text(
                      'Welcome to Nafas!',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.theme.text(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              NafasDataWidget.of(context)!.toggleThemeMode();
            },
            child: UserConsumer(
              builder: (context, user) {
                if (user != null) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl ?? ''),
                  );
                }
                return AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(
                    child: Icon(
                      Icons.account_circle,
                      color: context.theme.secondaryTextColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
