// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Scaffold].

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample>
    with SingleTickerProviderStateMixin {
  static const int tabCount = 3;
  String appBarTitle = 'Tab 0';

  TickerProvider get tickerProvider => this;

  late final TabController tabController =
      // #region body
      TabController(vsync: tickerProvider, length: tabCount)..addListener(() {
        if (!tabController.indexIsChanging) {
          setState(() {
            // Rebuild the enclosing scaffold with a new AppBar title
            appBarTitle = 'Tab ${tabController.index}';
          });
        }
      });
  // #endregion body

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        bottom: TabBar(
          controller: tabController,
          tabs: List<Widget>.generate(
            tabCount,
            (int index) => Tab(text: 'Item $index'),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List<Widget>.generate(
          tabCount,
          (int index) => Center(child: Text('Content $index')),
        ),
      ),
    );
  }
}
