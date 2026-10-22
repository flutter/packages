// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [RadioListTile].

enum Meridiem { am, pm }

class RadioListTileExample extends StatelessWidget {
  const RadioListTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    const ColoredBox(
      color: Colors.green,
      child: Material(
        child: RadioListTile<Meridiem>(
          tileColor: Colors.red,
          title: Text('AM'),
          value: Meridiem.am,
        ),
      ),
    )
    // #endregion body
    ;
  }
}
