// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<MyRoute>(path: '/product/:id')
class MyRoute extends GoRouteData {
  const MyRoute(this.id);
  final int id;
}
