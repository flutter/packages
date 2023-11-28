// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'Default implementation of PointerInterceptorPlatform should throw unimplemented error',
      () {
    final PointerInterceptorPlatform unimplementedPointerInterceptorPlatform =
        UnimplementedPointerInterceptorPlatform();

    final Container testChild = Container();
    expect(
        () => unimplementedPointerInterceptorPlatform.buildWidget(
            child: testChild),
        throwsUnimplementedError);
  });
}

class UnimplementedPointerInterceptorPlatform
    extends PointerInterceptorPlatform {}
