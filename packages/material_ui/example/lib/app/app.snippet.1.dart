// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialApp].

class MaterialAppExample extends StatelessWidget {
  const MaterialAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          return Scaffold(appBar: AppBar(title: const Text('Home Route')));
        },
        '/about': (BuildContext context) {
          return Scaffold(appBar: AppBar(title: const Text('About Route')));
        },
      },
    )
    // #endregion body
    ;
  }
}
