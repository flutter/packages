// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clip diagnostics hide the default and report a non-default value', () {
    expect(SvgPicture.string('<svg/>').toString(), isNot(contains('clipBehavior')));
    expect(
      SvgPicture.string('<svg/>', clipBehavior: Clip.none).toString(),
      contains('clipBehavior: none'),
    );
  });
}
