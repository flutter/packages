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
      body: CarouselView.weighted(
        scrollDirection: Axis.vertical,
        flexWeights: const <int>[
          1,
        ], // Or any positive integers as long as the length of the array is 1.
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
