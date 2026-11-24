// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Tab.height].

class TabHeightExample extends StatelessWidget {
  const TabHeightExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // #region body
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(20.0),
            child: TabBar(
              tabs: <Widget>[
                Tab(text: 'Tab 1', height: 20.0),
                Tab(text: 'Tab 2', height: 20.0),
              ],
            ),
          ),
          // #endregion body
        ),
      ),
    );
  }
}
