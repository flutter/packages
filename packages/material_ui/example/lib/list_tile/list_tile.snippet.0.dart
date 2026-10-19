// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [ListTile].

class ListTileExample extends StatelessWidget {
  const ListTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const ColoredBox(
      color: Colors.green,
      child: Material(
        child: ListTile(
          title: Text('ListTile with red background'),
          tileColor: Colors.red,
        ),
      ),
    )
    // #endregion body
    ;
  }
}
