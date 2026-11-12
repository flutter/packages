// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SwitchListTile].

class SwitchListTileExample extends StatelessWidget {
  const SwitchListTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    ColoredBox(
      color: Colors.green,
      child: Material(
        child: SwitchListTile(
          tileColor: Colors.red,
          title: const Text('SwitchListTile with red background'),
          value: true,
          onChanged: (bool value) {},
        ),
      ),
    )
    // #endregion body
    ;
  }
}
