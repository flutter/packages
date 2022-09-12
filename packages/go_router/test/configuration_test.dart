// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/configuration.dart';

void main() {
  test('throws when parentNavigatorKey is not an ancestor', () {
    final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> a = GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> b = GlobalKey<NavigatorState>();

    expect(
      () {
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            GoRoute(
              path: '/a',
              builder: _mockScreenBuilder,
              routes: <RouteBase>[
                ShellRoute(
                  navigatorKey: a,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'b',
                      builder: _mockScreenBuilder,
                    )
                  ],
                ),
                ShellRoute(
                  navigatorKey: b,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'c',
                      parentNavigatorKey: a,
                      builder: _mockScreenBuilder,
                    )
                  ],
                ),
              ],
            ),
          ],
          redirectLimit: 10,
          topRedirect: (GoRouterState state) {
            return null;
          },
        );
      },
      throwsAssertionError,
    );
  });

  test('throws when ShellRoute has no children', () {
    final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>();
    expect(
      () {
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              routes: <RouteBase>[],
            ),
          ],
          redirectLimit: 10,
          topRedirect: (GoRouterState state) {
            return null;
          },
        );
      },
      throwsAssertionError,
    );
  });
}

class _MockScreen extends StatelessWidget {
  const _MockScreen({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

Widget _mockScreenBuilder(BuildContext context, GoRouterState state) =>
    _MockScreen(key: state.pageKey);
