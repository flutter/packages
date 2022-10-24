// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0 &&
        MediaQuery.of(context).size.width < 800;
  }
}

class TestBreakpoint400 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width > 400;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1000;
  }
}

class TestBreakpoint1000 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class NeverOnBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return false;
  }
}
