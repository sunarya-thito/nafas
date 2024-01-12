import 'package:flutter/material.dart';

class ActivityData {
  final Widget image;
  final String message;
  final List<ActivityContentData> content;

  const ActivityData({
    required this.image,
    required this.message,
    required this.content,
  });
}

class ActivityContentData {
  final Widget title;
  final Widget content;
  final bool primary;

  const ActivityContentData({
    required this.title,
    required this.content,
    this.primary = false,
  });
}

class ActivityDetailsPage extends StatefulWidget {
  const ActivityDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  _ActivityDetailsPageState createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
