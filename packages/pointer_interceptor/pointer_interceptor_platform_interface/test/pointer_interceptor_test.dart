// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';
import 'package:pointer_interceptor_platform_interface/src/pointer_interceptor_method_channel.dart';

class MockPointerInterceptorPlatform
    with MockPlatformInterfaceMixin
    implements PointerInterceptorPlatform {
  @override
  Widget buildWidget(
      {required Widget child,
      bool intercepting = true,
      bool debug = false,
      Key? key}) {
    return const Text('mock pointer interceptor widget');
  }
}

void main() {
  final PointerInterceptorPlatform initialPlatform =
      PointerInterceptorPlatform.instance;

  test('$MethodChannelPointerInterceptor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPointerInterceptor>());
  });
}
