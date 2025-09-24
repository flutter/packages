// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/json_example.dart';

part 'json_nested_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router, title: _appTitle);

  final GoRouter _router = GoRouter(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  name: 'Home',
  routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<JsonRoute>(path: 'json')],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class JsonRoute extends GoRouteData with $JsonRoute {
  const JsonRoute(this.json);

  final JsonExampleNested<JsonExample> json;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      JsonScreen(json: json.child);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(_appTitle)),
    body: ListView(
      children: <Widget>[
        for (final JsonExample json in jsonData)
          ListTile(
            title: Text(json.name),
            onTap:
                () => JsonRoute(
                  JsonExampleNested<JsonExample>(child: json),
                ).go(context),
          ),
      ],
    ),
  );
}

class JsonScreen extends StatelessWidget {
  const JsonScreen({required this.json, super.key});
  final JsonExample json;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(json.name)),
    body: ListView(
      key: ValueKey<String>(json.id),
      children: <Widget>[Text(json.id), Text(json.name)],
    ),
  );
}

const String _appTitle = 'GoRouter Example: builder';
