// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  Widget _buildMaterial() {
    return
    // #region body
    Material(
      color: Colors.teal[900],
      child: Center(
        child: Ink(
          color: Colors.yellow,
          width: 200.0,
          height: 100.0,
          child: InkWell(
            onTap: () {
              /* ... */
            },
            child: const Center(child: Text('YELLOW')),
          ),
        ),
      ),
    )
    // #endregion body
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _buildMaterial());
  }
}
