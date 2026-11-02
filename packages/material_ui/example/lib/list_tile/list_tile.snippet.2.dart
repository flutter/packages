// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [ListTile].

class ListTileExample extends StatelessWidget {
  const ListTileExample({super.key, this.act = 1});

  final int act;

  int get _act => act;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    ListTile(
      leading: const Icon(Icons.flight_land),
      title: const Text("Trix's airplane"),
      subtitle: _act != 2
          ? const Text('The airplane is only in Act II.')
          : null,
      enabled: _act == 2,
      onTap: () {
        /* react to the tile being tapped */
      },
    )
    // #endregion body
    ;
  }
}
