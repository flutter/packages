// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [PopupMenuItem].

enum Menu { itemOne, itemTwo }

class PopupMenuItemExample extends StatelessWidget {
  const PopupMenuItemExample({super.key, this.onSelected});

  final ValueChanged<Menu>? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        // #region body
        const PopupMenuItem<Menu>(value: Menu.itemOne, child: Text('Item 1')),
        // #endregion body
      ],
    );
  }
}
