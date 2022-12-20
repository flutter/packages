// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('does not call builder when not enabled', (tester) async {
    final AnimatedSamplerBuilder builder =
        expectAsync4((image, size, offset, canvas) {}, count: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedSampler(
          builder,
          enabled: false,
          child: SizedBox(),
        ),
      ),
    );
  });

  testWidgets('starts calling builder once enabled', (tester) async {
    final AnimatedSamplerBuilder builder =
        expectAsync4((image, size, offset, canvas) {}, count: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedSampler(
          builder,
          enabled: false,
          child: SizedBox(),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedSampler(
          builder,
          enabled: true,
          child: SizedBox(),
        ),
      ),
    );
  });

  testWidgets('rebuilds when child layer is updated', (tester) async {
    final AnimatedSamplerBuilder builder =
        expectAsync4((image, size, offset, canvas) {}, count: 2);

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedSampler(
          builder,
          child: RepaintBoundary(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // Pump the next frame to animate `CircularProgressIndicator`.
    await tester.pump(Duration(seconds: 1));
  });
}
