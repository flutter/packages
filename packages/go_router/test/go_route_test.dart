// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('throws when a builder is not set', () {
    expect(() => GoRoute(path: '/'), throwsA(isAssertionError));
  });

  test('throws when a path is empty', () {
    expect(() => GoRoute(path: ''), throwsA(isAssertionError));
  });

  test('does not throw when only redirect is provided', () {
    GoRoute(path: '/', redirect: (_, __) => '/a');
  });
}
