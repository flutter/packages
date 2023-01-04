// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await ShaderBuilder.precacheShader('shaders/sampler.frag');
  });

  testWidgets('AnimatedSampler captures child widgets in texture',
      (WidgetTester tester) async {
    final GlobalKey globalKey = GlobalKey();
    bool usedShader = false;
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: globalKey,
        child: ShaderBuilder(assetKey: 'shaders/sampler.frag',
            (BuildContext context, FragmentShader shader, Widget? child) {
          return AnimatedSampler((ui.Image image, Size size, Canvas canvas) {
            usedShader = true;
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);
            shader.setImageSampler(0, image);

            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          }, child: Container(color: Colors.red));
        }),
      ),
    ));

    expect(usedShader, true);

    ByteData? snapshot;
    await tester.runAsync(() async {
      snapshot = await (await (globalKey.currentContext?.findRenderObject()
                  as RenderRepaintBoundary?)!
              .toImage())
          .toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    });

    // Validate that color is Colors.red from child widget.
    expect(_readColorFromBuffer(snapshot!, 0), Colors.red.shade500);
  });
}

Color _readColorFromBuffer(ByteData data, int offset) {
  final int r = data.getUint8(offset);
  final int g = data.getUint8(offset + 1);
  final int b = data.getUint8(offset + 2);
  final int a = data.getUint8(offset + 3);
  return Color.fromARGB(a, r, g, b);
}
