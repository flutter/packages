// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// TODO(dit): Delete this file, https://github.com/flutter/flutter/issues/151498
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  test('Web tests are disabled', () {
    print('Noop. Tests fail on CI with --web-renderer=canvaskit');
    print('Delete this file when solving issue: flutter/flutter#151498');
  });
}
