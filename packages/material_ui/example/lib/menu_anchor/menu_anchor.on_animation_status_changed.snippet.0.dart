// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MenuAnchor.onAnimationStatusChanged].

class MenuAnchorExample extends StatefulWidget {
  const MenuAnchorExample({super.key});

  @override
  State<MenuAnchorExample> createState() => _MenuAnchorExampleState();
}

class _MenuAnchorExampleState extends State<MenuAnchorExample> {
  AnimationStatus animationStatus = AnimationStatus.dismissed;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    MenuAnchor(
      animated: true,
      onAnimationStatusChanged: (AnimationStatus status) {
        // Typically, animationStatus would be stored in a State object.
        animationStatus = status;
      },
      menuChildren: <Widget>[
        MenuItemButton(onPressed: () {}, child: const Text('Menu Item')),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (animationStatus.isForwardOrCompleted) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert),
            );
          },
    )
    // #endregion body
    ;
  }
}
