// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Lifecycle regression tests for the geometry render link, blend group, and
// geometry cache.
//
// These drive the render objects directly: headless runs report
// ImageFilter.isShaderFilterSupported == false, so LiquidGlassBlendGroup never
// builds its render object through the widget tree here.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_blend_group.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/src/engine/render_liquid_glass_geometry.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';
import 'package:liquid_glass_widgets/src/engine/shaders.dart';

const _settings = LiquidGlassSettings(thickness: 20, blur: 0);

void main() {
  late ui.FragmentShader geometryShader;
  setUpAll(() async {
    geometryShader =
        (await ui.FragmentProgram.fromAsset(ShaderKeys.blendedGeometry))
            .fragmentShader();
  });

  RenderLiquidGlassBlendGroup blendGroupFor(
    GeometryRenderLink renderLink,
    GlassGroupLink link,
  ) =>
      RenderLiquidGlassBlendGroup(
        renderLink: renderLink,
        devicePixelRatio: 1,
        geometryShader: geometryShader,
        settings: _settings,
        link: link,
        blend: 0,
      );

  group('GeometryRenderLink registration', () {
    test('registering the same geometry twice keeps one entry', () {
      final link = GeometryRenderLink();
      final geometry = blendGroupFor(link, GlassGroupLink());

      link
        ..registerGeometry(geometry)
        ..registerGeometry(geometry);
      expect(link.shapes, hasLength(1));

      link.unregisterGeometry(geometry);
      expect(link.shapes, isEmpty);
    });

    test('swapping the link while detached registers once, on attach', () {
      final first = GeometryRenderLink();
      final second = GeometryRenderLink();
      final geometry = blendGroupFor(first, GlassGroupLink());

      geometry.renderLink = second;
      expect(second.shapes, isEmpty, reason: 'not attached yet');

      geometry.attach(PipelineOwner());
      expect(first.shapes, isEmpty);
      expect(second.shapes, [geometry]);

      geometry.detach();
      expect(second.shapes, isEmpty, reason: 'no entry outlives detach');
    });

    test('swapping the link while attached moves the registration', () {
      final first = GeometryRenderLink();
      final second = GeometryRenderLink();
      final geometry = blendGroupFor(first, GlassGroupLink())
        ..attach(PipelineOwner());
      expect(first.shapes, [geometry]);

      geometry.renderLink = second;
      expect(first.shapes, isEmpty);
      expect(second.shapes, [geometry]);

      geometry.detach();
      expect(second.shapes, isEmpty);
    });
  });

  group('RenderLiquidGlassBlendGroup.dispose', () {
    test('stops the group link calling into the disposed render object', () {
      final link = GlassGroupLink();
      final blendGroup = blendGroupFor(GeometryRenderLink(), link);
      expect(link.onShapeTransformChanged, isNotNull);

      blendGroup.dispose();
      expect(link.onShapeTransformChanged, isNull);
      // Would reach markNeedsPaint on the disposed render object if the
      // listener were still attached.
      expect(link.notifyListeners, returnsNormally);
    });

    test("leaves a replacement's transform callback in place", () {
      // Flutter creates the replacement before disposing the old object.
      final link = GlassGroupLink();
      final old = blendGroupFor(GeometryRenderLink(), link);
      final replacement = blendGroupFor(GeometryRenderLink(), link);

      old.dispose();
      expect(link.onShapeTransformChanged, isNotNull);

      replacement.dispose();
      expect(link.onShapeTransformChanged, isNull);
    });

    test('is safe after the group link itself was disposed', () {
      final link = GlassGroupLink();
      final blendGroup = blendGroupFor(GeometryRenderLink(), link);
      link.dispose();
      expect(blendGroup.dispose, returnsNormally);
    });
  });

  group('UnrenderedGeometryCache.renderAsync', () {
    UnrenderedGeometryCache cache(ui.Picture picture, Rect matteBounds) =>
        UnrenderedGeometryCache(
          matte: picture,
          matteBounds: matteBounds,
          bounds: matteBounds,
          shapes: const [],
          path: Path(),
        );

    ui.Picture record() {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 8, 8),
        Paint(),
      );
      return recorder.endRecording();
    }

    testWidgets('releases the recorded picture', (tester) async {
      final picture = record();
      final rendered = await tester.runAsync(
        () => cache(picture, const Rect.fromLTWH(0, 0, 8, 8)).renderAsync(),
      );

      expect(picture.debugDisposed, isTrue);
      expect(rendered!.matte.width, 8);
      rendered.dispose();
    });

    testWidgets('releases the recorded picture for an empty matte',
        (tester) async {
      final picture = record();
      final rendered = await tester.runAsync(
        () => cache(picture, Rect.zero).renderAsync(),
      );

      expect(picture.debugDisposed, isTrue);
      expect(rendered!.matte.width, 1);
      rendered.dispose();
    });
  });
}
