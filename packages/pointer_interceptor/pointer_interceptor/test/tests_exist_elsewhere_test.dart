// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tell the user where to find the real tests', () {
    print('---');
    // TODO(louisehsu): add non web integration tests.
    print('Please find platform tests in their respective packages.');
    print('---');
  });
}
