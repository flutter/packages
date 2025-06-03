// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedStatefulShellRoute<StatefulShellRouteNoConstConstructor>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<BranchAData>(),
  ],
)
class StatefulShellRouteNoConstConstructor extends StatefulShellRouteData {}

@TypedStatefulShellRoute<StatefulShellRouteWithConstConstructor>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<BranchAData>(),
  ],
)
class StatefulShellRouteWithConstConstructor extends StatefulShellRouteData {
  const StatefulShellRouteWithConstConstructor();
}

class BranchAData extends StatefulShellBranchData {
  const BranchAData();
}
