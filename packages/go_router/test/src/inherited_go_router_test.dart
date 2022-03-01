// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/inherited_go_router.dart';

void main() {
  test('does not update on changes', () {
    final oldGoRouter = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Page1(),
      ),
    ]);
    final newGoRouter = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Page2(),
      ),
    ]);
    final oldInheritedGoRouter = InheritedGoRouter(
      goRouter: oldGoRouter,
      child: Container(),
    );
    final newInheritedGoRouter = InheritedGoRouter(
      goRouter: newGoRouter,
      child: Container(),
    );
    final shouldNotify = newInheritedGoRouter.updateShouldNotify(
      oldInheritedGoRouter,
    );
    expect(shouldNotify, false);
  });

  test('adds [goRouter] as a diagnostics property', () {
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Page1(),
        ),
      ],
    );
    final inheritedGoRouter = InheritedGoRouter(
      goRouter: goRouter,
      child: Container(),
    );
    final properties = DiagnosticPropertiesBuilder();
    inheritedGoRouter.debugFillProperties(properties);
    expect(properties.properties.length, 1);
    expect(properties.properties.first, isA<DiagnosticsProperty<GoRouter>>());
    expect(properties.properties.first.value, goRouter);
  });
}

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}
