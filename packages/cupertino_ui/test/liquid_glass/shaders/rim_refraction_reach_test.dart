// Guards the reach of the premium shader's rim refraction.
//
// At the rim the surface normal is nearly horizontal, and the displacement
// `refract()` returns grows with the glass's thickness, not with its shape. On
// a pill a few dozen pixels tall it reached past the opposite edge, and any
// text sitting there came through as rainbow noise along the rim once the
// chromatic dispersion split it. The render shader holds the reach to half the
// matte's shorter side.
//
// Source-level on purpose, like gles_flip_guard_test.dart: `flutter test`
// renders through Skia, so the premium shader never runs and no widget or
// golden test can see the rim.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the render shader caps the displacement before sampling', () {
    final source = File('shaders/liquid_glass_render.frag').readAsStringSync();

    final cap = source.indexOf(
      'float maxReach = 0.5 * min(uGeometrySize.x, uGeometrySize.y);',
    );
    final scale = source.indexOf('displacement *= uOpticalProps.w;');
    final firstSample = source.indexOf('screenUV + displacement * invTexSize');

    expect(cap, isNonNegative, reason: 'The reach cap is gone.');
    expect(scale, isNonNegative);
    expect(firstSample, isNonNegative);
    // After the pixel-ratio scale, which is what makes it physical pixels like
    // uGeometrySize, and before anything samples with it.
    expect(cap, greaterThan(scale));
    expect(cap, lessThan(firstSample));
    expect(source, contains('displacement *= maxReach / reach;'));
  });

  test('uncapped, a pill rim reaches past its own far side', () {
    // Why the guard exists, in numbers: the app-level optics that showed the
    // artefact — thickness 30, refractive index 1.59, a 2× display — on a pill
    // 36 logical pixels tall.
    const dpr = 2.0;
    const thickness = 30.0 * dpr / 3.0; // uThickness in physical pixels
    const baseHeight = thickness * 8.0;
    const index = 1.59;
    const pillHeight = 36.0 * dpr;

    // A normal tilted 80° at the last row inside the rim.
    const tilt = 80 * math.pi / 180;
    final normal = [math.sin(tilt), 0.0, math.cos(tilt)];
    final eta = 1 / index;
    // refract(I = (0,0,-1), N, eta)
    final cosI = normal[2];
    final k = 1 - eta * eta * (1 - cosI * cosI);
    final t = [
      -eta * 0 - (eta * -cosI + math.sqrt(k)) * normal[0],
      0.0,
      -eta - (eta * -cosI + math.sqrt(k)) * normal[2],
    ];
    final reach = t[0].abs() * baseHeight / t[2].abs();

    expect(reach, greaterThan(pillHeight));
    expect(
        math.min(reach, 0.5 * pillHeight), lessThanOrEqualTo(pillHeight / 2));
  });
}
