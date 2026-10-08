import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_blend_group.dart';
import 'package:liquid_glass_widgets/src/engine/shaders.dart';

// The iOS 27 material's uniforms sit at the end of each shader. The Dart side
// sets them by float index, and an index one short would silently land in
// the uniform before them, so pin both to the last slot.
void main() {
  test('uNativeEdge is the float after the geometry shader shape array',
      () async {
    final shader =
        (await ui.FragmentProgram.fromAsset(ShaderKeys.blendedGeometry))
            .fragmentShader();
    const index = 8 + LiquidGlassBlendGroup.maxShapesPerLayer * 7;
    shader.setFloat(index, 1);
    expect(() => shader.setFloat(index + 1, 0), throwsA(anything));
  });

  test('uBodyShade ends the render shader float uniforms at slot 45', () async {
    final shader =
        (await ui.FragmentProgram.fromAsset(ShaderKeys.liquidGlassRender))
            .fragmentShader();
    shader.setFloat(45, 1);
    expect(() => shader.setFloat(46, 0), throwsA(anything));
  });
}
