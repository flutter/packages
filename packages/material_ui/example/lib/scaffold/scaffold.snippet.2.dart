// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Scaffold].

class ScaffoldExample extends StatelessWidget {
  const ScaffoldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Body')),
      persistentFooterButtons: <Widget>[
        TextButton(onPressed: () {}, child: const Text('Cancel')),
        TextButton(onPressed: () {}, child: const Text('Save')),
      ],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
    // #endregion body
  }
}
