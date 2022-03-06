// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_delegate.dart';

import '../go_router_test.dart';

GoRouterDelegate createGoRouterDelegate() => GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (_, __) => Container()),
      ],
    ).routerDelegate;

void main() {
  test('throws when a builder is not set', () {
    final GoRouterDelegate delegate = createGoRouterDelegate();
    final GoRoute route = GoRoute(path: '/');
    void build() => route.builder(
          DummyBuildContext(),
          GoRouterState(
            delegate,
            location: '/foo',
            subloc: '/bar',
            name: 'baz',
          ),
        );
    expect(build, throwsException);
  });
}
