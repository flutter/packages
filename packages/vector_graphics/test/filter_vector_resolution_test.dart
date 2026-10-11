// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML text adjacency is intentional in the layout regression fixtures.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/render_vector_graphic.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  testWidgets('vector-only filters retain one picture across layout, fit and DPR changes', (
    WidgetTester tester,
  ) async {
    final loader = _Loader(
      encodeSvg(
        xml:
            '<svg width="24" height="24"><defs><filter id="f"><feOffset dx="1"/>'
            '<feOffset dy="2"/></filter></defs><rect width="16" height="16" filter="url(#f)"/></svg>',
        debugName: 'vector filter resolution',
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      ).buffer.asByteData(),
    );
    ui.Picture? first;
    for (final (double size, double dpr, BoxFit fit) in <(double, double, BoxFit)>[
      (24, 1, BoxFit.contain),
      (240, 1, BoxFit.cover),
      (240, 3, BoxFit.fill),
      (36, 2, BoxFit.none),
    ]) {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(devicePixelRatio: dpr),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: createCompatVectorGraphic(loader: loader, fit: fit),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(() => vg.waitForPendingDecodes());
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      final Finder finder = find.byElementPredicate(
        (Element e) => e is RenderObjectElement && e.renderObject is RenderPictureVectorGraphic,
      );
      final PictureInfo info = tester.renderObject<RenderPictureVectorGraphic>(finder).pictureInfo;
      expect(info.hasFilters, isTrue);
      expect(info.requiresRasterResolution, isFalse);
      first ??= info.picture;
      expect(info.picture, same(first));
      expect(loader.loads, 1);
    }
  });
}

class _Loader extends BytesLoader {
  _Loader(this.data);
  final ByteData data;
  final List<void> _loads = <void>[];
  int get loads => _loads.length;
  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    _loads.add(null);
    return data;
  }
}
