// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/inherited_go_router.dart';

void main() {
  group('updateShouldNotify', () {
    test('does not update when goRouter does not change', () {
      final GoRouter goRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedGoRouterChange(
        oldGoRouter: goRouter,
        newGoRouter: goRouter,
      );
      expect(shouldNotify, false);
    });

    test('updates when goRouter changes', () {
      final GoRouter oldGoRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final GoRouter newGoRouter = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, __) => const Page2(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedGoRouterChange(
        oldGoRouter: oldGoRouter,
        newGoRouter: newGoRouter,
      );
      expect(shouldNotify, true);
    });
  });

  test('adds [goRouter] as a diagnostics property', () {
    final GoRouter goRouter = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const Page1(),
        ),
      ],
    );
    final InheritedGoRouter inheritedGoRouter = InheritedGoRouter(
      goRouter: goRouter,
      child: Container(),
    );
    final DiagnosticPropertiesBuilder properties =
        DiagnosticPropertiesBuilder();
    inheritedGoRouter.debugFillProperties(properties);
    expect(properties.properties.length, 1);
    expect(properties.properties.first, isA<DiagnosticsProperty<GoRouter>>());
    expect(properties.properties.first.value, goRouter);
  });
}

bool setupInheritedGoRouterChange({
  required GoRouter oldGoRouter,
  required GoRouter newGoRouter,
}) {
  final InheritedGoRouter oldInheritedGoRouter = InheritedGoRouter(
    goRouter: oldGoRouter,
    child: Container(),
  );
  final InheritedGoRouter newInheritedGoRouter = InheritedGoRouter(
    goRouter: newGoRouter,
    child: Container(),
  );
  return newInheritedGoRouter.updateShouldNotify(
    oldInheritedGoRouter,
  );
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
