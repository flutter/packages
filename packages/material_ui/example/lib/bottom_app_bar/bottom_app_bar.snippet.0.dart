// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [BottomAppBar].

class BottomAppBarExample extends StatelessWidget {
  const BottomAppBarExample({super.key, this.bottomAppBarContents});

  final Widget? bottomAppBarContents;

  @override
  Widget build(BuildContext context) {
    return
    // #region body
    Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: bottomAppBarContents,
      ),
      floatingActionButton: const FloatingActionButton(onPressed: null),
    )
    // #endregion body
    ;
  }
}
