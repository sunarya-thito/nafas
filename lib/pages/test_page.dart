import 'package:flutter/material.dart';
import 'package:nafas/component/paginated_list_view.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late PaginationController<int> controller;

  @override
  void initState() {
    super.initState();
    controller = PaginationController(
      fetchPage: (lastItem) async {
        await Future.delayed(Duration(milliseconds: 500));
        if (lastItem == null) {
          return [0];
        }
        return [lastItem + 1];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.reset();
      },
      child: PaginatedListView<int>(
        controller: controller,
        builder: (context, item) {
          return Text(item.toString());
        },
        separator: Divider(),
      ),
    );
  }
}
