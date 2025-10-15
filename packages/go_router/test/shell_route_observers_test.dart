// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('ShellRoute observers test', () {
    final ShellRoute shell = ShellRoute(
      observers: <NavigatorObserver>[HeroController()],
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return SafeArea(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return Container();
          },
        ),
      ],
    );

    expect(shell.observers!.length, 1);
  });
}
