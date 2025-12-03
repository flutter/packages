// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';
import 'package:test/test.dart';

void main() {
  test('Should be able to import JavaOptions', () async {
    const javaOptions = JavaOptions();
    expect(javaOptions, isNotNull);
  });

  test('Should be able to import ObjcOptions', () async {
    const objcOptions = ObjcOptions();
    expect(objcOptions, isNotNull);
  });

  test('Should be able to import SwiftOptions', () async {
    const swiftOptions = SwiftOptions();
    expect(swiftOptions, isNotNull);
  });

  test('Should be able to import KotlinOptions', () async {
    const kotlinOptions = KotlinOptions();
    expect(kotlinOptions, isNotNull);
  });
}
