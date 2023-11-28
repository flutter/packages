// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Default implementation of PointerInterceptor should return child', () {
    final PointerInterceptorPlatform pointerInterceptorPlatform =
        PointerInterceptorPlatform.instance;

    final Container testChild = Container();
    expect(pointerInterceptorPlatform.buildWidget(child: testChild), testChild);
  });
}
