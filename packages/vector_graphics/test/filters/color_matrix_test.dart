// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/color_matrix.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(referenceDescription('color_defaults'), () => expectBrowserReference('color_defaults'));
  test(referenceDescription('color_identity'), () => expectBrowserReference('color_identity'));
  test(referenceDescription('color_swap'), () => expectBrowserReference('color_swap'));
  test(referenceDescription('color_invert'), () => expectBrowserReference('color_invert'));
  test(referenceDescription('color_alpha_bias'), () => expectBrowserReference('color_alpha_bias'));
  test(referenceDescription('color_gray'), () => expectBrowserReference('color_gray'));
  test(
    referenceDescription('color_saturate_half'),
    () => expectBrowserReference('color_saturate_half'),
  );
  test(
    referenceDescription('color_saturate_over'),
    () => expectBrowserReference('color_saturate_over'),
  );
  test(
    referenceDescription('color_saturate_negative'),
    () => expectBrowserReference('color_saturate_negative'),
  );
  test(
    referenceDescription('color_saturate_default'),
    () => expectBrowserReference('color_saturate_default'),
  );
  test(
    referenceDescription('color_hue_default'),
    () => expectBrowserReference('color_hue_default'),
  );
  test(referenceDescription('color_hue_90'), () => expectBrowserReference('color_hue_90'));
  test(
    referenceDescription('color_hue_negative'),
    () => expectBrowserReference('color_hue_negative'),
  );
  test(referenceDescription('color_hue_cycle'), () => expectBrowserReference('color_hue_cycle'));
  test(referenceDescription('color_luminance'), () => expectBrowserReference('color_luminance'));
  test(
    referenceDescription('color_luminance_ignored'),
    () => expectBrowserReference('color_luminance_ignored'),
  );
  test(
    referenceDescription('color_short_values'),
    () => expectBrowserReference('color_short_values'),
  );
  test(referenceDescription('color_subregion'), () => expectBrowserReference('color_subregion'));
  test(referenceDescription('color_chain'), () => expectBrowserReference('color_chain'));
  test(
    referenceDescription('color_source_alpha'),
    () => expectBrowserReference('color_source_alpha'),
  );
  test(
    referenceDescription('color_linear_gray'),
    () => expectBrowserReference('color_linear_gray'),
  );
  test(
    referenceDescription('color_linear_matrix'),
    () => expectBrowserReference('color_linear_matrix'),
  );
  test(
    referenceDescription('color_linear_luminance'),
    () => expectBrowserReference('color_linear_luminance'),
  );
  test(
    referenceDescription('color_linear_alpha_bias'),
    () => expectBrowserReference('color_linear_alpha_bias'),
  );
  test(referenceDescription('color_style'), () => expectBrowserReference('color_style'));
  test(referenceDescription('color_inherited'), () => expectBrowserReference('color_inherited'));
  test(
    referenceDescription('color_linear_default'),
    () => expectBrowserReference('color_linear_default'),
  );
  test(referenceDescription('color_initial'), () => expectBrowserReference('color_initial'));

  for (final type in <String>['matrix', 'saturate', 'hueRotate']) {
    for (final value in <String>['NaN', 'Infinity', '-Infinity', 'invalid', '1e999']) {
      test('reject nonfinite $type values=$value', () {
        expect(
          () => colorMatrixValues(
            VectorFilter('feColorMatrix', <String, String>{'type': type, 'values': value}),
          ),
          throwsFormatException,
        );
      });
    }
  }
  for (final count in <int>[0, 1, 19, 21, 30]) {
    test('incorrect matrix length $count is identity', () {
      expect(
        colorMatrixValues(
          VectorFilter('feColorMatrix', <String, String>{
            'values': List<String>.filled(count, '0').join(' '),
          }),
        ),
        <double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
      );
    });
  }
  test('unknown type is diagnosed', () {
    expect(
      () =>
          colorMatrixValues(VectorFilter('feColorMatrix', const <String, String>{'type': 'wrong'})),
      throwsFormatException,
    );
  });
  for (final (String type, String values, List<int> expected) in <(String, String, List<int>)>[
    ('saturate', '0', <int>[54, 54, 54, 255]),
    ('saturate', '1', <int>[255, 0, 0, 255]),
    ('hueRotate', '0', <int>[255, 0, 0, 255]),
    ('hueRotate', '360', <int>[255, 0, 0, 255]),
    ('luminanceToAlpha', '', <int>[0, 0, 0, 54]),
    ('matrix', '0 0 0 0 .25 0 0 0 0 .5 0 0 0 0 .75 0 0 0 0 .5', <int>[64, 128, 191, 128]),
  ]) {
    test('independent channel expectation $type $values', () async {
      final ui.Image image = await renderSvg(
        filterSvg('<feColorMatrix type="$type" values="$values"/>'),
      );
      try {
        final Uint8List data = await pixels(image);
        const int start = (40 * 128 + 40) * 4;
        for (var c = 0; c < 4; c++) {
          expect(data[start + c], closeTo(expected[c], 2), reason: 'channel $c');
        }
      } finally {
        image.dispose();
      }
    });
  }
  test('constant alpha affects transparent pixels within the subregion', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feColorMatrix values="0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1" x="16" y="16" width="80" height="80"/>',
      ),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data.sublist((20 * 128 + 20) * 4, (20 * 128 + 20) * 4 + 4), <int>[255, 0, 0, 255]);
    expect(data[(10 * 128 + 10) * 4 + 3], 0);
  });
}
