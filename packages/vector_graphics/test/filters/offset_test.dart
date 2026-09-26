// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final direction in <String>['negative', 'positive']) {
    test(
      'SourceAlpha outside region matches browser: $direction',
      () => expectBrowserReference('offset_alpha_outside_$direction'),
    );
  }
  test(
    referenceDescription('offset_source_clipped'),
    () => expectBrowserReference('offset_source_clipped'),
  );
  test(
    referenceDescription('offset_unknown_input'),
    () => expectBrowserReference('offset_unknown_input'),
  );
  test(referenceDescription('offset_root'), () => expectBrowserReference('offset_root'));
  test(referenceDescription('offset_use'), () => expectBrowserReference('offset_use'));
  test(
    referenceDescription('offset_use_filtered_source'),
    () => expectBrowserReference('offset_use_filtered_source'),
  );
  test(
    referenceDescription('offset_quoted_url'),
    () => expectBrowserReference('offset_quoted_url'),
  );
  test(
    referenceDescription('offset_zero_scale'),
    () => expectBrowserReference('offset_zero_scale'),
  );
  test(referenceDescription('offset_clipped'), () => expectBrowserReference('offset_clipped'));

  test(referenceDescription('offset_basic'), () => expectBrowserReference('offset_basic'));
  test(referenceDescription('offset_negative'), () => expectBrowserReference('offset_negative'));
  test(
    referenceDescription('offset_fractional'),
    () => expectBrowserReference('offset_fractional'),
  );
  test(referenceDescription('offset_alpha'), () => expectBrowserReference('offset_alpha'));
  test(referenceDescription('offset_bbox'), () => expectBrowserReference('offset_bbox'));
  test(referenceDescription('offset_subregion'), () => expectBrowserReference('offset_subregion'));
  test(referenceDescription('offset_chain'), () => expectBrowserReference('offset_chain'));
  test(referenceDescription('offset_source'), () => expectBrowserReference('offset_source'));
  test(referenceDescription('offset_overwrite'), () => expectBrowserReference('offset_overwrite'));
  test(referenceDescription('offset_transform'), () => expectBrowserReference('offset_transform'));
  test(referenceDescription('offset_rotate'), () => expectBrowserReference('offset_rotate'));
  test(referenceDescription('offset_forward'), () => expectBrowserReference('offset_forward'));
  test(referenceDescription('offset_opacity'), () => expectBrowserReference('offset_opacity'));
  test(
    referenceDescription('offset_default_region'),
    () => expectBrowserReference('offset_default_region'),
  );
  test(referenceDescription('offset_nested'), () => expectBrowserReference('offset_nested'));
  test(referenceDescription('offset_viewbox'), () => expectBrowserReference('offset_viewbox'));
  for (final (int dx, int dy) in <(int, int)>[
    (0, 0),
    (1, 0),
    (0, 1),
    (-1, 0),
    (0, -1),
    (8, 12),
    (-8, -12),
    (80, 80),
    (-80, -80),
    (128, 0),
    (0, -128),
  ]) {
    test('offset exact pixels ($dx,$dy)', () async {
      final ui.Image image = await renderSvg(filterSvg('<feOffset dx="$dx" dy="$dy"/>'));
      try {
        final Uint8List data = await pixels(image);
        for (var y = 0; y < 128; y++) {
          for (var x = 0; x < 128; x++) {
            final bool inside = x >= 32 + dx && x < 64 + dx && y >= 32 + dy && y < 64 + dy;
            final int p = (y * 128 + x) * 4;
            if (data[p + 3] != (inside ? 255 : 0) || (inside && data[p] != 255)) {
              fail('Unexpected pixel at ($x,$y) for offset ($dx,$dy): ${data.sublist(p, p + 4)}');
            }
          }
        }
      } finally {
        image.dispose();
      }
    });
  }
  for (final attribute in <String>['dx', 'dy']) {
    for (final value in <String>['NaN', 'Infinity', 'invalid', '1 2', '10px', '10%']) {
      test('reject malformed $attribute=$value', () async {
        await expectLater(
          renderSvg(filterSvg('<feOffset $attribute="$value"/>')),
          throwsA(
            isA<VectorGraphicsDecodeException>().having(
              (e) => e.toString(),
              'diagnostic',
              contains('Invalid filter number'),
            ),
          ),
        );
      });
    }
  }
  test('omitted parameters preserve source', () async {
    final ui.Image image = await renderSvg(filterSvg('<feOffset/>'));
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[(40 * 128 + 40) * 4], 255);
    expect(data[(10 * 128 + 10) * 4 + 3], 0);
  });
  test('picture scales without rasterizing the offset', () async {
    for (final scale in <double>[1, 2, 3]) {
      final ui.Image image = await renderSvg(filterSvg('<feOffset dx="8" dy="4"/>'), scale: scale);
      final Uint8List data = await pixels(image);
      expect(data[((40 * scale).round() * image.width + (44 * scale).round()) * 4 + 3], 255);
      image.dispose();
    }
  });
}
