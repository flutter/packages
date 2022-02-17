// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

enum ScaffoldTab { books, authors, settings }

class BookstoreScaffold extends StatelessWidget {
  const BookstoreScaffold({
    required this.selectedTab,
    required this.child,
    Key? key,
  }) : super(key: key);

  final ScaffoldTab selectedTab;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AdaptiveNavigationScaffold(
          selectedIndex: selectedTab.index,
          body: child,
          onDestinationSelected: (idx) {
            switch (ScaffoldTab.values[idx]) {
              case ScaffoldTab.books:
                context.go('/books');
                break;
              case ScaffoldTab.authors:
                context.go('/authors');
                break;
              case ScaffoldTab.settings:
                context.go('/settings');
                break;
            }
          },
          destinations: const [
            AdaptiveScaffoldDestination(
              title: 'Books',
              icon: Icons.book,
            ),
            AdaptiveScaffoldDestination(
              title: 'Authors',
              icon: Icons.person,
            ),
            AdaptiveScaffoldDestination(
              title: 'Settings',
              icon: Icons.settings,
            ),
          ],
        ),
      );
}
