// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(referenceDescription('merge_empty'), () => expectBrowserReference('merge_empty'));
  test(referenceDescription('merge_single'), () => expectBrowserReference('merge_single'));
  test(referenceDescription('merge_two'), () => expectBrowserReference('merge_two'));
  test(referenceDescription('merge_reverse'), () => expectBrowserReference('merge_reverse'));
  test(referenceDescription('merge_repeat'), () => expectBrowserReference('merge_repeat'));
  test(referenceDescription('merge_default'), () => expectBrowserReference('merge_default'));
  test(referenceDescription('merge_unknown'), () => expectBrowserReference('merge_unknown'));
  test(referenceDescription('merge_source'), () => expectBrowserReference('merge_source'));
  test(referenceDescription('merge_alpha'), () => expectBrowserReference('merge_alpha'));
  test(referenceDescription('merge_linear'), () => expectBrowserReference('merge_linear'));
  test(referenceDescription('merge_subregion'), () => expectBrowserReference('merge_subregion'));
  test(referenceDescription('merge_zero'), () => expectBrowserReference('merge_zero'));
  test(referenceDescription('merge_chain'), () => expectBrowserReference('merge_chain'));
  test(referenceDescription('merge_nested'), () => expectBrowserReference('merge_nested'));
  test(
    referenceDescription('merge_transform'),
    () => expectBrowserReference('merge_transform', allowOnePixelClipRounding: true),
  );

  for (final count in <int>[0, 1, 2, 3, 4, 8]) {
    test('source-over alpha for $count identical inputs', () async {
      final String nodes = List<String>.filled(count, '<feMergeNode/>').join();
      final ui.Image image = await renderSvg(
        filterSvg('<feFlood flood-color="red" flood-opacity=".5"/><feMerge>$nodes</feMerge>'),
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      final int expected = (255 * (1 - 1 / (1 << count))).round();
      expect(data[3], closeTo(expected, 2));
      if (count > 0) {
        expect(data[0], 255);
      }
    });
  }
  for (final (String order, List<int> expected) in <(String, List<int>)>[
    ('<feMergeNode in="red"/><feMergeNode in="blue"/>', <int>[85, 0, 170, 192]),
    ('<feMergeNode in="blue"/><feMergeNode in="red"/>', <int>[170, 0, 85, 192]),
  ]) {
    test('independent source-over color $order', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feFlood flood-color="red" flood-opacity=".5" result="red"/><feFlood flood-color="blue" flood-opacity=".5" result="blue"/><feMerge>$order</feMerge>',
        ),
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      for (var c = 0; c < 4; c++) {
        expect(data[c], closeTo(expected[c], 2));
      }
    });
  }
  test('non-merge child is diagnosed', () async {
    await expectLater(renderSvg(filterSvg('<feMerge><feOffset/></feMerge>')), throwsA(anything));
  });
}
