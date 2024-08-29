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
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Detail Page 1'),
            onTap: () => <void>{
              context.goNamed(DetailPage.name,
                  queryParameters: <String, String>{'itemName': '1'}),
            },
          ),
          ListTile(
            title: const Text('Detail Page 2'),
            onTap: () => <void>{
              context.goNamed(DetailPage.name,
                  queryParameters: <String, String>{'itemName': '2'}),
            },
          ),
        ],
      ),
    );
  }
}
