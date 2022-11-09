// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Can cache fragment shaders', (WidgetTester tester) async {
    bool shaderLoaded = false;
    final Widget child = ShaderBuilder(
        (BuildContext context, FragmentShader shader, Widget? child) {
      shaderLoaded = true;
      return child ?? const SizedBox();
    }, assetKey: 'shaders/solid_color.frag');

    await tester.pumpWidget(child);

    // Shader isn't cached yet.
    expect(shaderLoaded, isFalse);

    await tester.pumpWidget(child);
    await tester.pumpWidget(child);

    expect(shaderLoaded, isTrue);

    // Shader is still cached with a new widget.
    bool sameShaderLoaded = false;
    await tester.pumpWidget(ShaderBuilder(
        (BuildContext context, FragmentShader shader, Widget? child) {
      sameShaderLoaded = true;
      return child ?? const SizedBox();
    }, assetKey: 'shaders/solid_color.frag'));

    expect(sameShaderLoaded, true);
  });

  testWidgets(
      'ShaderBuilder.precacheShader reports flutter error if invalid asset is provided',
      (WidgetTester tester) async {
    await ShaderBuilder.precacheShader('shaders/bogus.frag');

    expect(tester.takeException(), isNotNull);
  });

  testWidgets(
      'ShaderBuilder.precacheShader makes shader available '
      'synchronously when future completes', (WidgetTester tester) async {
    await ShaderBuilder.precacheShader('shaders/sampler.frag');

    bool shaderLoaded = false;
    await tester.pumpWidget(ShaderBuilder(
        (BuildContext context, FragmentShader shader, Widget? child) {
      shaderLoaded = true;
      return child ?? const SizedBox();
    }, assetKey: 'shaders/sampler.frag'));

    expect(shaderLoaded, true);
  });

  testWidgets(
      'ShaderBuilder.precacheShader reports flutter error if invalid asset is provided',
      (WidgetTester tester) async {
    await ShaderBuilder.precacheShader('shaders/bogus.frag');

    expect(tester.takeException(), isNotNull);
  });

  testWidgets(
      'ShaderBuilder reports flutter error if invalid asset is provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(ShaderBuilder(
        (BuildContext context, FragmentShader shader, Widget? child) {
      return child ?? const SizedBox();
    }, assetKey: 'shaders/bogus.frag'));

    expect(tester.takeException(), isNotNull);
  });
}
