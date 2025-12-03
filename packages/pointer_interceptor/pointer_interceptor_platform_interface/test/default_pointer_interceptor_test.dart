// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Default implementation of PointerInterceptor does not do anything', () {
    final PointerInterceptorPlatform defaultPointerInterceptor =
        PointerInterceptorPlatform.instance;

    final testChild = Container();
    expect(defaultPointerInterceptor.buildWidget(child: testChild), testChild);
  });
}
