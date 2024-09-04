// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'detail_page.dart';

/// The detail overview page.
class DetailOverviewPage extends StatelessWidget {
  /// Construct the detail overview page.
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
