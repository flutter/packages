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
      color: Colors.grey[800],
      child: Center(
        child: Ink.image(
          image: const AssetImage('cat.jpeg'),
          fit: BoxFit.cover,
          width: 300.0,
          height: 200.0,
          child: InkWell(
            onTap: () {
              /* ... */
            },
            child: const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'KITTEN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
