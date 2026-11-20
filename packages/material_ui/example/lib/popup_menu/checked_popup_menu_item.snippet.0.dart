// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [CheckedPopupMenuItem].

enum Commands { heroAndScholar, hurricaneCame }

class CheckedPopupMenuItemExample extends StatefulWidget {
  const CheckedPopupMenuItemExample({super.key});

  @override
  State<CheckedPopupMenuItemExample> createState() =>
      _CheckedPopupMenuItemExampleState();
}

class _CheckedPopupMenuItemExampleState
    extends State<CheckedPopupMenuItemExample> {
  bool _heroAndScholar = false;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    PopupMenuButton<Commands>(
      onSelected: (Commands result) {
        switch (result) {
          case Commands.heroAndScholar:
            setState(() {
              _heroAndScholar = !_heroAndScholar;
            });
          case Commands.hurricaneCame:
            // ...handle hurricane option
            break;
          // ...other items handled here
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Commands>>[
        CheckedPopupMenuItem<Commands>(
          checked: _heroAndScholar,
          value: Commands.heroAndScholar,
          child: const Text('Hero and scholar'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<Commands>(
          value: Commands.hurricaneCame,
          child: ListTile(leading: Icon(null), title: Text('Bring hurricane')),
        ),
        // ...other items listed here
      ],
    )
    // #endregion body
    ;
  }
}
