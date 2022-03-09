// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Nested Navigation';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        redirect: (_) => '/family/${Families.data[0].id}',
      ),
      GoRoute(
        path: '/family/:fid',
        builder: (BuildContext context, GoRouterState state) =>
            FamilyTabsScreen(
          key: state.pageKey,
          selectedFamily: Families.family(state.params['fid']!),
        ),
        routes: <GoRoute>[
          GoRoute(
            path: 'person/:pid',
            builder: (BuildContext context, GoRouterState state) {
              final Family family = Families.family(state.params['fid']!);
              final Person person = family.person(state.params['pid']!);

              return PersonScreen(family: family, person: person);
            },
          ),
        ],
      ),
    ],

    // show the current router location as the user navigates page to page; note
    // that this is not required for nested navigation but it is useful to show
    // the location as it changes
    navigatorBuilder:
        (BuildContext context, GoRouterState state, Widget child) => Material(
      child: Column(
        children: <Widget>[
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(state.location),
          ),
        ],
      ),
    ),
  );
}

/// The family tabs screen.
class FamilyTabsScreen extends StatefulWidget {
  /// Creates a [FamilyTabsScreen].
  FamilyTabsScreen({required Family selectedFamily, Key? key})
      : index =
            Families.data.indexWhere((Family f) => f.id == selectedFamily.id),
        super(key: key) {
    assert(index != -1);
  }

  /// The tab index.
  final int index;

  @override
  _FamilyTabsScreenState createState() => _FamilyTabsScreenState();
}

class _FamilyTabsScreenState extends State<FamilyTabsScreen>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: Families.data.length,
      vsync: this,
      initialIndex: widget.index,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FamilyTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.index = widget.index;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.title),
          bottom: TabBar(
            controller: _controller,
            tabs: <Tab>[
              for (final Family f in Families.data) Tab(text: f.name)
            ],
            onTap: (int index) => _tap(context, index),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            for (final Family f in Families.data) FamilyView(family: f)
          ],
        ),
      );

  void _tap(BuildContext context, int index) =>
      context.go('/family/${Families.data[index].id}');
}

/// The family view.
class FamilyView extends StatefulWidget {
  /// Creates a [FamilyView].
  const FamilyView({required this.family, Key? key}) : super(key: key);

  /// The family to display.
  final Family family;

  @override
  State<FamilyView> createState() => _FamilyViewState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state, like scroll
/// position and text fields when switching tabs, as well as when popping back
/// from sub screens. To use the mixin override [wantKeepAlive] and call
/// `super.build(context)` in build.
///
/// In this example if you make a web build and make the browser window so low
/// that you have to scroll to see the last person on each family tab, you will
/// see that state is kept when you switch tabs and when you open a person
/// screen and pop back to the family.
class _FamilyViewState extends State<FamilyView>
    with AutomaticKeepAliveClientMixin {
  // Override `wantKeepAlive` when using `AutomaticKeepAliveClientMixin`.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Call `super.build` when using `AutomaticKeepAliveClientMixin`.
    super.build(context);
    return ListView(
      children: <Widget>[
        for (final Person p in widget.family.people)
          ListTile(
            title: Text(p.name),
            onTap: () =>
                context.go('/family/${widget.family.id}/person/${p.id}'),
          ),
      ],
    );
  }
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.family, required this.person, Key? key})
      : super(key: key);

  /// The family this person belong to.
  final Family family;

  /// The person to be displayed.
  final Person person;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(person.name)),
        body: Text('${person.name} ${family.name} is ${person.age} years old'),
      );
}
