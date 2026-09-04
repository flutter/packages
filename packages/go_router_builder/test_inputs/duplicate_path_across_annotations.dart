// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $FirstHomeRoute {}
mixin $SecondHomeRoute {}

@TypedGoRoute<FirstHomeRoute>(path: '/home')
class FirstHomeRoute extends GoRouteData with $FirstHomeRoute {}

@TypedGoRoute<SecondHomeRoute>(path: '/home')
class SecondHomeRoute extends GoRouteData with $SecondHomeRoute {}
