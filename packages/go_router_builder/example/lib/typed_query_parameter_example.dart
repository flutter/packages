// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'typed_query_parameter_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);

  final GoRouter _router = GoRouter(
    initialLocation: '/int-route',
    routes: $appRoutes,
  );
}

@TypedGoRoute<IntRoute>(path: '/int-route')
class IntRoute extends GoRouteData with $IntRoute {
  IntRoute({
    @TypedQueryParameter(name: 'intField') this.intField,
    @TypedQueryParameter(name: 'int_field_with_default_value')
    this.intFieldWithDefaultValue = 1,
    @TypedQueryParameter(name: 'int field') this.intFieldWithSpace,
  });

  final int? intField;
  final int intFieldWithDefaultValue;
  final int? intFieldWithSpace;
  @override
  Widget build(BuildContext context, GoRouterState state) => Screen(
    intField: intField,
    intFieldWithDefaultValue: intFieldWithDefaultValue,
    intFieldWithSpace: intFieldWithSpace,
  );
}

class Screen extends StatelessWidget {
  const Screen({
    required this.intField,
    required this.intFieldWithDefaultValue,
    this.intFieldWithSpace,
    super.key,
  });

  final int? intField;
  final int intFieldWithDefaultValue;
  final int? intFieldWithSpace;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Go router with custom URI parameter names'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('intField:'),
            subtitle: Text('$intField'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = (intField ?? 0) + 1;
              IntRoute(
                intField: newValue,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: intFieldWithSpace,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('intFieldWithDefaultValue:'),
            subtitle: Text('$intFieldWithDefaultValue'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = intFieldWithDefaultValue + 1;
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: newValue,
                intFieldWithSpace: intFieldWithSpace,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('intFieldWithSpace:'),
            subtitle: Text('$intFieldWithSpace'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = (intFieldWithSpace ?? 0) + 1;
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: newValue,
              ).go(context);
            },
          ),
        ],
      ),
    ),
  );
}
