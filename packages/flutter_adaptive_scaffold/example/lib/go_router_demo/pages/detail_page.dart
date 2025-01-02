// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// The detail page.
class DetailPage extends StatelessWidget {
  /// Construct the detail page.
  const DetailPage({super.key, required this.itemName});

  /// The path for the detail page.
  static const String path = 'detail';

  /// The name for the detail page.
  static const String name = 'Detail';

  /// The item name for the detail page.
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Text('Detail Page: $itemName'),
      ),
    );
  }
}
