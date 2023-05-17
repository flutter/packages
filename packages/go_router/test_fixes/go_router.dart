// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

void main() {
  const GoRouterState state = GoRouterState();
  final GoRouter router = GoRouter(routes: <RouteBase>[]);
  state.fullpath;
  state.params;
  state.subloc;
  state.queryParams;
  state.namedLocation(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
  router.namedLocation(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
  router.goNamed(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
  router.pushNamed(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
  router.pushReplacementNamed(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
  router.replaceNamed(
    'name',
    params: <String, String>{},
    queryParams: <String, String>{},
  );
}
