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
    expect(bad / (a.length / 4), lessThanOrEqualTo(.005), reason: '$name differing pixels');
  } finally {
    expected.dispose();
  }
}

void main() {
  setUp(() => svg.cache.clear());
  for (final name in <String>['integration_pattern_contains_mask']) {
    for (final vg.RenderingStrategy strategy in vg.RenderingStrategy.values) {
      for (final memory in <bool>[false, true]) {
        testWidgets('SvgPicture ${memory ? 'memory' : 'string'} $strategy $name matches browser', (
          WidgetTester tester,
        ) async {
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
        });
      }
    }
  }
}
