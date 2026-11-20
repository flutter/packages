// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildButton() {
    return
    // #region body
    ElevatedButton(
      style: ElevatedButton.styleFrom(splashFactory: InkSparkle.splashFactory),
      child: const Text('Sparkle!'),
      onPressed: () {},
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: _buildButton())),
    );
  }
}
