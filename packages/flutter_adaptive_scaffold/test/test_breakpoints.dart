// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 0 &&
        MediaQuery.sizeOf(context).width < 800;
  }
}

class TestBreakpoint400 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 400;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 800 &&
        MediaQuery.sizeOf(context).width < 1000;
  }
}

class TestBreakpoint1000 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1000 &&
        MediaQuery.sizeOf(context).width < 1200;
  }
}

class TestBreakpoint1200 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1200 &&
        MediaQuery.sizeOf(context).width < 1600;
  }
}

class TestBreakpoint1600 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1600;
  }
}

class NeverOnBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return false;
  }
}

class AppBarAlwaysOnBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return true;
  }
}
