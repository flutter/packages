// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

@TypedStatefulShellBranch<StatefulShellBranchWithObserversData>()
class StatefulShellBranchWithObserversData extends StatefulShellBranchData {
  const StatefulShellBranchWithObserversData();

  static const String $initialLocation = '/main/second-tab';
  static const List<NavigatorObserver> $observers = <NavigatorObserver>[];
}
