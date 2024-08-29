import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'detail_page.dart';

class DetailOverviewPage extends StatelessWidget {
  const DetailOverviewPage({super.key});

  /// The path for the detail page.
  static const String path = 'detail-overview';

  /// The name for the detail page.
  static const String name = 'DetailOverview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Overview Page'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Item $index'),
            onTap: () {
              context.goNamed(
                DetailPage.name,
                queryParameters: <String, String>{'itemName': '$index'},
              );
            },
          );
        },
      ),
    );
  }
}
