// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tell the user how to run tests within "testing" directory', () {
    print('---');
    print('This package also has client-server tests.');
    print('Use `flutter test testing` to run them.');
    print('---');
  });
}
