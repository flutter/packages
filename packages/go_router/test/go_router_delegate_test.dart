// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_match.dart';
import 'package:go_router/src/go_router_delegate.dart';
import 'package:go_router/src/go_router_error_page.dart';

GoRouterDelegate createGoRouterDelegate({
  Listenable? refreshListenable,
}) {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(
        path: '/error',
        builder: (_, __) => const GoRouterErrorScreen(null),
      ),
    ],
    refreshListenable: refreshListenable,
  );
  return router.routerDelegate;
}

void main() {
  group('pop', () {
    test('removes the last element', () {
      final GoRouterDelegate delegate = createGoRouterDelegate()
        ..push('/error')
        ..addListener(expectAsync0(() {}));
      final GoRouteMatch last = delegate.matches.last;
      delegate.pop();
      expect(delegate.matches.length, 1);
      expect(delegate.matches.contains(last), false);
    });

    test('throws when it pops more than matches count', () {
      final GoRouterDelegate delegate = createGoRouterDelegate()
        ..push('/error');
      expect(
        () => delegate
          ..pop()
          ..pop(),
        throwsException,
      );
    });
  });

  test('dispose unsubscribes from refreshListenable', () {
    final FakeRefreshListenable refreshListenable = FakeRefreshListenable();
    createGoRouterDelegate(refreshListenable: refreshListenable).dispose();
    expect(refreshListenable.unsubscribed, true);
  });
}

class FakeRefreshListenable extends ChangeNotifier {
  bool unsubscribed = false;
  @override
  void removeListener(VoidCallback listener) {
    unsubscribed = true;
    super.removeListener(listener);
  }
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
