// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import 'use_cases.dart';

class NavigationRailUseCase extends UseCase {
  NavigationRailUseCase();

  @override
  String get name => 'NavigationRail';

  @override
  String get route => '/navigation-rail';

  @override
  List<Tag> get tags => <Tag>[Tag.batch1, Tag.core];

  @override
  Widget build(BuildContext context) => const NavRailExample();
}

class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: groupAlignment,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: labelType,
            leading: showLeading
                ? FloatingActionButton(
                    tooltip: 'Add',
                    elevation: 0,
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    child: const Icon(Icons.add),
                  )
                : const SizedBox(),
            trailing: showTrailing
                ? IconButton(
                    tooltip: 'More',
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    icon: const Icon(Icons.more_horiz_rounded),
                  )
                : const SizedBox(),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                padding: EdgeInsets.all(4),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.book),
                padding: EdgeInsets.all(4),
                label: Text('Second'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                padding: EdgeInsets.all(4),
                label: Text('Third'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('selectedIndex: $_selectedIndex'),
                const SizedBox(height: 20),
                Semantics(
                  container: true,
                  child: Column(
                    children: <Widget>[
                      Text('Label type: ${labelType.name}'),
                      const SizedBox(height: 10),
                      SegmentedButton<NavigationRailLabelType>(
                        segments: const <ButtonSegment<NavigationRailLabelType>>[
                          ButtonSegment<NavigationRailLabelType>(
                            value: NavigationRailLabelType.none,
                            label: Text('None'),
                          ),
                          ButtonSegment<NavigationRailLabelType>(
                            value: NavigationRailLabelType.selected,
                            label: Text('Selected'),
                          ),
                          ButtonSegment<NavigationRailLabelType>(
                            value: NavigationRailLabelType.all,
                            label: Text('All'),
                          ),
                        ],
                        selected: <NavigationRailLabelType>{labelType},
                        onSelectionChanged: (Set<NavigationRailLabelType> newSelection) {
                          setState(() {
                            labelType = newSelection.single;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  container: true,
                  child: Column(
                    children: <Widget>[
                      Text('Group alignment: $groupAlignment'),
                      const SizedBox(height: 10),
                      SegmentedButton<double>(
                        segments: const <ButtonSegment<double>>[
                          ButtonSegment<double>(value: -1.0, label: Text('Top')),
                          ButtonSegment<double>(value: 0.0, label: Text('Center')),
                          ButtonSegment<double>(value: 1.0, label: Text('Bottom')),
                        ],
                        selected: <double>{groupAlignment},
                        onSelectionChanged: (Set<double> newSelection) {
                          setState(() {
                            groupAlignment = newSelection.single;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OverflowBar(
                  spacing: 10.0,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showLeading = !showLeading;
                        });
                      },
                      child: Text(showLeading ? 'Hide Leading' : 'Show Leading'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showTrailing = !showTrailing;
                        });
                      },
                      child: Text(showTrailing ? 'Hide Trailing' : 'Show Trailing'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
