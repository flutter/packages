// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialApp].

void main() {
  runApp(const MaterialAppExample());
}

class MaterialAppExample extends StatelessWidget {
  const MaterialAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region content
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    )
    // #endregion content
    ;
  }
}
