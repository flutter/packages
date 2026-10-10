// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/src/render_vector_graphic.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

const source =
    '<svg width="24" height="24"><defs><filter id="f" '
    'filterUnits="userSpaceOnUse" x="0" y="0" width="24" height="24" color-interpolation-filters="sRGB"> '
    '<feMerge><feMergeNode/><feMergeNode/></feMerge><feMerge><feMergeNode/><feMergeNode/></feMerge><feMerge><feMergeNode/><feMergeNode/></feMerge><feMerge><feMergeNode/><feMergeNode/></feMerge><feMerge><feMergeNode/><feMergeNode/></feMerge> '
    '</filter></defs><g filter="url(#f)"><circle cx="12" cy="12" r="9" fill="red"/> '
    '<path d="M 2 4 L 22 20" stroke="white" stroke-width=".15"/></g></svg>';

void main() {
  final loader = _Loader(
    encodeSvg(
      xml: source,
      debugName: 'resolution',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    ).buffer.asByteData(),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => vg.waitForPendingDecodes());
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  }

  PictureInfo info(WidgetTester tester) {
    final Finder finder = find.byElementPredicate(
      (Element e) => e is RenderObjectElement && e.renderObject is RenderPictureVectorGraphic,
    );
    return tester.renderObject<RenderPictureVectorGraphic>(finder).pictureInfo;
  }

  Future<void> mount(
    WidgetTester tester, {
    required double width,
    required double height,
    double dpr = 1,
    double? resolution,
    BoxFit fit = BoxFit.contain,
    BytesLoader? asset,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(devicePixelRatio: dpr),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: createCompatVectorGraphic(
                loader: asset ?? loader,
                fit: fit,
                filterRasterScale: resolution,
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<Uint8List> draw(PictureInfo info, double scale) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..scale(scale)
      ..drawPicture(info.picture);
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage((24 * scale).round(), (24 * scale).round());
    picture.dispose();
    final Uint8List bytes = (await image.toByteData())!.buffer.asUint8List();
    image.dispose();
    return bytes;
  }

  for (final BoxFit fit in BoxFit.values) {
    testWidgets('automatic filter resolution follows layout and $fit', (WidgetTester tester) async {
      await mount(tester, width: 240, height: 120, dpr: 3, fit: fit);
      final PictureInfo automatic = info(tester);
      expect(automatic.requiresRasterResolution, isTrue);
      final FittedSizes fitted = applyBoxFit(fit, const Size(24, 24), const Size(240, 120));
      final double needed =
          3 *
          (fitted.destination.width / fitted.source.width >
                  fitted.destination.height / fitted.source.height
              ? fitted.destination.width / fitted.source.width
              : fitted.destination.height / fitted.source.height);
      var bucket = 1.0;
      while (bucket < needed) {
        bucket *= 2;
      }
      expect(automatic.filterRasterScale, bucket);
      final PictureInfo expected = (await tester.runAsync(
        () => decodeVectorGraphics(
          loader.data,
          locale: null,
          textDirection: TextDirection.ltr,
          clipViewbox: true,
          loader: loader,
          filterRasterScale: bucket,
        ),
      ))!;
      final List<Uint8List> pixels = (await tester.runAsync(
        () async => <Uint8List>[await draw(automatic, 30), await draw(expected, 30)],
      ))!;
      expected.picture.dispose();
      expect(pixels[0], pixels[1]);
    });
  }

  testWidgets('nearby layouts reuse a resolution bucket, larger layouts redecode', (
    WidgetTester tester,
  ) async {
    await mount(tester, width: 100, height: 100);
    final ui.Picture first = info(tester).picture;
    await mount(tester, width: 110, height: 110);
    expect(info(tester).picture, same(first));
    await mount(tester, width: 240, height: 240);
    expect(info(tester).picture, isNot(same(first)));
    final ui.Picture larger = info(tester).picture;
    await mount(tester, width: 240, height: 240, dpr: 3);
    expect(info(tester).picture, isNot(same(larger)));
  });

  testWidgets('explicit resolution ignores layout but updates on configuration change', (
    WidgetTester tester,
  ) async {
    await mount(tester, width: 100, height: 100, resolution: 4);
    final ui.Picture first = info(tester).picture;
    await mount(tester, width: 240, height: 240, dpr: 3, resolution: 4);
    expect(info(tester).picture, same(first));
    await mount(tester, width: 240, height: 240, dpr: 3, resolution: 32);
    expect(info(tester).picture, isNot(same(first)));
  });

  for (final replace in <bool>[false, true]) {
    testWidgets('first decode fits a large source before allocating textures, replacing=$replace', (
      WidgetTester tester,
    ) async {
      if (replace) {
        await mount(tester, width: 32, height: 32);
      }
      final large = _Loader(
        encodeSvg(
          xml: source.replaceAll('24', '4096'),
          debugName: 'large source in small widget',
          enableClippingOptimizer: false,
          enableMaskingOptimizer: false,
          enableOverdrawOptimizer: false,
        ).buffer.asByteData(),
      );
      await mount(tester, width: 32, height: 32, asset: large);
      expect(info(tester).size, const Size(4096, 4096));
      expect(info(tester).filterRasterScale, 1 / 128);
      expect(info(tester).requiresRasterResolution, isTrue);
    });
  }

  testWidgets('version 1 nested masks use the first layout and follow resizing', (
    WidgetTester tester,
  ) async {
    final String definitions = <String>[
      for (var i = 0; i < 15; i++)
        '<mask id="m$i"><rect width="4096" height="4096" fill="white" ${i == 0 ? '' : 'mask="url(#m${i - 1})"'}/></mask>',
    ].join();
    final asset = _Loader(
      encodeSvg(
        xml:
            '<svg width="4096" height="4096"><defs>$definitions</defs> '
            '<rect width="4096" height="4096" fill="red" mask="url(#m14)"/></svg>',
        debugName: 'large masked source',
        enableMaskingOptimizer: false,
        enableClippingOptimizer: false,
        enableOverdrawOptimizer: false,
      ).buffer.asByteData(),
    );
    expect(asset.data.getUint8(4), 1);
    await mount(tester, width: 32, height: 32, asset: asset);
    expect(info(tester).requiresRasterResolution, isTrue);
    expect(info(tester).hasFilters, isFalse);
    expect(info(tester).filterRasterScale, 1 / 128);
    final ui.Picture first = info(tester).picture;
    await mount(tester, width: 64, height: 64, asset: asset);
    expect(info(tester).picture, isNot(same(first)));
    expect(info(tester).filterRasterScale, 1 / 64);
  });

  testWidgets('initial layout preserves intrinsic dimensions and imageBuilder timing', (
    WidgetTester tester,
  ) async {
    var builds = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: createCompatVectorGraphic(
                loader: loader,
                imageBuilder: (BuildContext context, Widget child) {
                  builds++;
                  return child;
                },
              ),
            ),
          ),
        ),
      ),
    );
    expect(builds, 0);
    await settle(tester);
    expect(builds, greaterThan(0));
    expect(tester.getSize(find.byType(FittedBox)), const Size(24, 24));
  });

  testWidgets('a late byte load cannot replace the current asset or its metadata', (
    WidgetTester tester,
  ) async {
    final pending = Completer<ByteData>();
    await mount(tester, width: 32, height: 32, asset: _DelayedLoader(pending.future));
    await mount(tester, width: 32, height: 32);
    final ui.Picture current = info(tester).picture;
    pending.complete(
      encodeSvg(
        xml: source.replaceAll('24', '4096'),
        debugName: 'stale large source',
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      ).buffer.asByteData(),
    );
    await settle(tester);
    expect(info(tester).picture, same(current));
    expect(info(tester).size, const Size(24, 24));
  });

  testWidgets('an initially empty layout waits until it becomes visible', (
    WidgetTester tester,
  ) async {
    await mount(tester, width: 0, height: 0);
    expect(
      find.byElementPredicate(
        (Element e) => e is RenderObjectElement && e.renderObject is RenderPictureVectorGraphic,
      ),
      findsNothing,
    );
    await mount(tester, width: 48, height: 48);
    expect(info(tester).filterRasterScale, 2);
  });
}

class _Loader extends BytesLoader {
  const _Loader(this.data);
  final ByteData data;
  @override
  Future<ByteData> loadBytes(BuildContext? context) async => data;
}

class _DelayedLoader extends BytesLoader {
  const _DelayedLoader(this.data);
  final Future<ByteData> data;
  @override
  Future<ByteData> loadBytes(BuildContext? context) => data;
}
