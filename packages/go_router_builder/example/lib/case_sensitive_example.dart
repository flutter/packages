// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'case_sensitive_example.g.dart';

void main() => runApp(CaseSensitivityApp());

class CaseSensitivityApp extends StatelessWidget {
  CaseSensitivityApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
      );

  final GoRouter _router = GoRouter(
    initialLocation: '/case-sensitive',
    routes: $appRoutes,
  );
}

@TypedGoRoute<CaseSensitiveRoute>(
  path: '/case-sensitive',
)
class CaseSensitiveRoute extends GoRouteData with _$CaseSensitiveRoute {
  const CaseSensitiveRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Screen(
        title: 'Case Sensitive',
      );
}

@TypedGoRoute<NotCaseSensitiveRoute>(
  path: '/not-case-sensitive',
  caseSensitive: false,
)
class NotCaseSensitiveRoute extends GoRouteData with _$NotCaseSensitiveRoute {
  const NotCaseSensitiveRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Screen(
        title: 'Not Case Sensitive',
      );
}

class Screen extends StatelessWidget {
  const Screen({required this.title, super.key});

  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Case Sensitive'),
              onTap: () => context.go('/case-sensitive'),
            ),
            ListTile(
              title: const Text('Not Case Sensitive'),
              onTap: () => context.go('/not-case-sensitive'),
            ),
          ],
        ),
      );
}
