// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedStatefulShellBranch<StatefulShellBranchWithPreloadData>()
class StatefulShellBranchWithPreloadData extends StatefulShellBranchData {
  const StatefulShellBranchWithPreloadData();

  static const String $initialLocation = '/main/second-tab';
  static const bool $preload = true;
}
