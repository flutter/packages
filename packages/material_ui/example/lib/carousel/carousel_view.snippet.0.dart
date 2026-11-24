// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildHome() {
    return
    // #region body
    Scaffold(
      body: CarouselView(
        scrollDirection: Axis.vertical,
        itemExtent: double.infinity,
        children: List<Widget>.generate(10, (int index) {
          return Center(child: Text('Item $index'));
        }),
      ),
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _buildHome());
  }
}
