// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg_example/readme_excerpts.dart' as excerpts;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example simple loadAsset works', () async {
    final Widget svg = excerpts.loadAsset();
    expect(svg, isNotNull);
  });

  test('example loadAsset with color filter works', () async {
    final Widget svg = excerpts.loadAsset();
    expect(svg, isNotNull);
  });

  test('example loadAsset with a non-existent asset works', () async {
    final Widget svg = excerpts.loadMissingAsset();
    expect(svg, isNotNull);
  });

  test('example loadAsset with a precompiled asset works', () async {
    final Widget svg = excerpts.loadPrecompiledAsset();
    expect(svg, isNotNull);
  });
}
