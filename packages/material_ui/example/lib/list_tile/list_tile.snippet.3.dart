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
    ListTile(
      leading: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: const CircleAvatar(),
        ),
      ),
      title: const Text('title'),
      dense: false,
    )
    // #endregion body
    ;
  }
}
