// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildCarousel() {
    return
    // #region body
    CarouselView.weightedBuilder(
      flexWeights: const <int>[1, 7, 1],
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return ColoredBox(
          color: Colors.primaries[index % Colors.primaries.length],
          child: Center(child: Text('Item $index')),
        );
      },
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: SizedBox(height: 200, child: _buildCarousel())),
    );
  }
}
