// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/src/pointer_interceptor_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPointerInterceptor platform = MethodChannelPointerInterceptor();
  test('buildWidget unimplemented', () async {
    expect(platform.buildWidget(child: const Text('text')),
        throwsUnimplementedError);
  });
}
