// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics_compat.dart' as vg;

Future<ui.Image> capture(WidgetTester tester, SvgPicture picture) async {
  final GlobalKey<State<StatefulWidget>> key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox(width: 128, height: 128, child: picture),
        ),
      ),
    ),
  );
  await tester.runAsync(() => vg.vg.waitForPendingDecodes());
  await tester.pumpAndSettle();
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() => boundary.toImage()))!;
}

Future<void> compareReference(ui.Image image, String name) async {
  final ui.Codec codec = await ui.instantiateImageCodec(
    File('test/filter_reference/$name.png').readAsBytesSync(),
  );
  final ui.Image expected = (await codec.getNextFrame()).image;
  codec.dispose();
  try {
    final Uint8List a = (await image.toByteData())!.buffer.asUint8List(),
        b = (await expected.toByteData())!.buffer.asUint8List();
    expect(image.width, expected.width);
    expect(image.height, expected.height);
    var difference = 0, bad = 0;
    for (var p = 0; p < a.length; p += 4) {
      var max = 0;
      for (var c = 0; c < 4; c++) {
        final int d = (a[p + c] - b[p + c]).abs();
        difference += d;
        if (d > max) {
          max = d;
        }
      }
      if (max > 20) {
        bad++;
      }
    }
    expect(difference / a.length, lessThanOrEqualTo(1), reason: '$name mean channel error');
    // Match the runtime's integration_material oracle: Gaussian approximation
    // differences are amplified by thresholded noise and two lighting stages.
    // All other fixtures retain the ordinary half-percent bound.
    final badPixelFraction = name == 'integration_material' ? .01 : .005;
    expect(
      bad / (a.length / 4),
      lessThanOrEqualTo(badPixelFraction),
      reason: '$name differing pixels',
    );
  } finally {
    expected.dispose();
  }
}

const String themed =
    '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128"><feFlood flood-color="currentColor"/></filter></defs><rect width="128" height="128" filter="url(#f)"/></svg>';
void main() {
  setUp(() => svg.cache.clear());
  for (final name in <String>[
    'integration_flood_group_opacity',
    'integration_pattern_contains_mask',
  ]) {
    for (final vg.RenderingStrategy strategy in vg.RenderingStrategy.values) {
      for (final memory in <bool>[false, true]) {
        testWidgets(
          'SvgPicture ${memory ? 'memory' : 'string'} $strategy $name matches reference',
          (WidgetTester tester) async {
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetDevicePixelRatio);
            final String source = File('test/filter_reference/$name.svg').readAsStringSync();
            final picture = memory
                ? SvgPicture.memory(
                    Uint8List.fromList(utf8.encode(source)),
                    renderingStrategy: strategy,
                  )
                : SvgPicture.string(source, renderingStrategy: strategy);
            final ui.Image image = await capture(tester, picture);
            try {
              await tester.runAsync(() => compareReference(image, name));
            } finally {
              image.dispose();
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  for (final vg.RenderingStrategy strategy in vg.RenderingStrategy.values) {
    testWidgets('text contributes to filter bounds with $strategy', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      final ui.Image image = await capture(
        tester,
        SvgPicture.string(
          '<svg width="128" height="128"><defs><filter id="f"> '
          '<feFlood flood-color="red"/></filter></defs> '
          '<g filter="url(#f)"><rect x="32" y="32" width="32" height="32"/> '
          '<text x="32" y="64">X</text></g></svg>',
          renderingStrategy: strategy,
        ),
      );
      try {
        final Uint8List data = (await tester.runAsync(
          () => image.toByteData(),
        ))!.buffer.asUint8List();
        expect(data.sublist((48 * 128 + 48) * 4, (48 * 128 + 48) * 4 + 4), <int>[255, 0, 0, 255]);
      } finally {
        image.dispose();
      }
      expect(tester.takeException(), isNull);
    });
    testWidgets('theme changes invalidate cached filter color with $strategy', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final color in <Color>[
        const Color(0xffff0000),
        const Color(0xff0000ff),
        const Color(0xffff0000),
      ]) {
        final ui.Image image = await capture(
          tester,
          SvgPicture.string(
            themed,
            theme: SvgTheme(currentColor: color),
            renderingStrategy: strategy,
          ),
        );
        final Uint8List data = (await tester.runAsync(
          () => image.toByteData(),
        ))!.buffer.asUint8List();
        image.dispose();
        expect(
          data.sublist((64 * 128 + 64) * 4, (64 * 128 + 64) * 4 + 4),
          color == const Color(0xffff0000) ? <int>[255, 0, 0, 255] : <int>[0, 0, 255, 255],
        );
      }
    });
  }
  testWidgets('filter failure reaches errorBuilder and a replacement can recover', (
    WidgetTester tester,
  ) async {
    Object? diagnostic;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.string(
          themed.replaceFirst('<feFlood flood-color="currentColor"/>', '<feUnsupported/>'),
          errorBuilder: (BuildContext context, Object error, StackTrace stack) {
            diagnostic = error;
            return const Text('filter failed');
          },
        ),
      ),
    );
    await tester.runAsync(() => vg.vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    expect(find.text('filter failed'), findsOneWidget);
    expect(diagnostic.toString(), contains('feUnsupported'));
    final ui.Image recovered = await capture(
      tester,
      SvgPicture.string(themed, theme: const SvgTheme(currentColor: Color(0xff00ff00))),
    );
    final Uint8List data = (await tester.runAsync(
      () => recovered.toByteData(),
    ))!.buffer.asUint8List();
    recovered.dispose();
    expect(data.sublist((64 * 128 + 64) * 4, (64 * 128 + 64) * 4 + 4), <int>[0, 255, 0, 255]);
    expect(tester.takeException(), isNull);
  });
}
