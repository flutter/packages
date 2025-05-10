// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$NamedEscapedRoute {}

@TypedGoRoute<NamedEscapedRoute>(path: '/named-route', name: r'named$Route')
class NamedEscapedRoute extends GoRouteData with _$NamedEscapedRoute {}
