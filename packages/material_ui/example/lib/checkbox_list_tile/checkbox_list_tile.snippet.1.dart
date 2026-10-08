// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [CheckboxListTile.onChanged].

class CheckboxListTileExample extends StatefulWidget {
  const CheckboxListTileExample({super.key});

  @override
  State<CheckboxListTileExample> createState() =>
      _CheckboxListTileExampleState();
}

class _CheckboxListTileExampleState extends State<CheckboxListTileExample> {
  bool? _throwShotAway = false;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    CheckboxListTile(
      value: _throwShotAway,
      onChanged: (bool? newValue) {
        setState(() {
          _throwShotAway = newValue;
        });
      },
      title: const Text('Throw away your shot'),
    )
    // #endregion body
    ;
  }
}
