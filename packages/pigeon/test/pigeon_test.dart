// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';
import 'package:test/test.dart';

void main() {
  test('Should be able to import JavaOptions', () async {
    const JavaOptions javaOptions = JavaOptions();
    expect(javaOptions, isNotNull);
  });

  test('Should be able to import ObjcOptions', () async {
    const ObjcOptions objcOptions = ObjcOptions();
    expect(objcOptions, isNotNull);
  });

  test('Should be able to import SwiftOptions', () async {
    const SwiftOptions swiftOptions = SwiftOptions();
    expect(swiftOptions, isNotNull);
  });
}
