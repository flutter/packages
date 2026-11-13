// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SliverAppBar].

class SliverAppBarExample extends StatelessWidget {
  const SliverAppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        // #region body
        SliverAppBar(
          expandedHeight: 150.0,
          flexibleSpace: const FlexibleSpaceBar(title: Text('Available seats')),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_circle),
              tooltip: 'Add new entry',
              onPressed: () {
                /* ... */
              },
            ),
          ],
        ),
        // #endregion body
      ],
    );
  }
}
