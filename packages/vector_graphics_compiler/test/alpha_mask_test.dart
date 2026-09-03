// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

// CSS Masking 的 mask-type:alpha（XML 属性与 style 两种写法）应生成
// alphaMask 指令（纯 alpha 合成语义）；未声明保持 luminance 的 mask。
void main() {
  const alphaAttrMask = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">
  <mask id="m" mask-type="alpha">
    <rect width="10" height="10" fill="#fff"/>
  </mask>
  <rect width="10" height="10" fill="#f00" mask="url(#m)"/>
</svg>
''';
  const alphaStyleMask = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">
  <mask id="m" style="mask-type:alpha">
    <rect width="10" height="10" fill="#fff"/>
  </mask>
  <rect width="10" height="10" fill="#f00" mask="url(#m)"/>
</svg>
''';
  const luminanceMask = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">
  <mask id="m">
    <rect width="10" height="10" fill="#fff"/>
  </mask>
  <rect width="10" height="10" fill="#f00" mask="url(#m)"/>
</svg>
''';

  List<DrawCommandType> maskTypes(String svg) => parse(
        svg,
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      )
          .commands
          .map((DrawCommand c) => c.type)
          .where((DrawCommandType t) =>
              t == DrawCommandType.mask || t == DrawCommandType.alphaMask)
          .toList();

  test('XML attribute mask-type=alpha encodes alphaMask', () {
    expect(maskTypes(alphaAttrMask), [DrawCommandType.alphaMask]);
  });

  test('style mask-type:alpha encodes alphaMask', () {
    expect(maskTypes(alphaStyleMask), [DrawCommandType.alphaMask]);
  });

  test('unspecified mask-type defaults to luminance mask', () {
    expect(maskTypes(luminanceMask), [DrawCommandType.mask]);
  });
}
