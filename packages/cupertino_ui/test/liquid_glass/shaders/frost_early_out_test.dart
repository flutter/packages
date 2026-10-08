// Guards the work the premium shader skips when it has no visible effect.
//
// The iOS 27 frost costs 45 backdrop taps per fragment for its ghost, plus a
// bilinear sample of 4 (12 with chromatic aberration) that the frost then
// replaces. The shader skips both where the result doesn't change: the ghost
// under a fully opaque cloud, the bilinear sample in the frosted body away from
// the hairline. It also skips the iOS 26 light block when there is no light to
// add, which is the case for both iOS 27 presets, and evaluates a squircle with
// equal top and bottom radii once instead of twice.
//
// Source-level on purpose, like rim_refraction_reach_test.dart: `flutter test`
// renders through Skia, so the premium shader never runs here.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _body(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature is gone.');
  var depth = 0;
  for (var i = source.indexOf('{', start); i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}' && --depth == 0) return source.substring(start, i + 1);
  }
  fail('unbalanced braces after $signature');
}

void main() {
  final render = File('shaders/liquid_glass_render.frag').readAsStringSync();

  test('an opaque cloud returns before the ghost taps', () {
    final frostAt = _body(render, 'vec3 frostAt(');
    final earlyOut = frostAt.indexOf('if (uFrost.x >= 1.0)');
    final ghostLoop = frostAt.indexOf('for (int j = -2; j <= 2; j++)');
    expect(earlyOut, isNonNegative,
        reason: 'The opaque-cloud early-out is gone.');
    expect(ghostLoop, isNonNegative);
    expect(earlyOut, lessThan(ghostLoop));
    // Exact, not a threshold: below 1 the ghost still shows through the mix.
    expect(frostAt, isNot(contains('uFrost.x >= 0.9')));
    expect(frostAt.substring(earlyOut, ghostLoop), contains('return cloud;'));
  });

  test('the frosted body takes one texel instead of the bilinear sample', () {
    final gate = render.indexOf('if (uFrost.x > 0.0 && hairline <= 0.0)');
    final bilinear = render.indexOf(
      'refractColor = textureBilinear(screenUV, physTexSize, invTexSize);',
    );
    final frost = render.indexOf('vec3 frost = frostAt(p, q, invTexSize);');
    expect(gate, isNonNegative, reason: 'The frosted-body gate is gone.');
    expect(gate, lessThan(bilinear));
    expect(gate, lessThan(frost));
    // Only the alpha survives in the body, so that is all it reads.
    final branch = render.substring(gate, bilinear);
    expect(branch, contains('texture(uBackgroundTexture, screenUV).a'));
    expect(branch, contains('refractColor = vec4(0.0, 0.0, 0.0, a);'));
    // The frost block still keeps only whether a backdrop was captured.
    expect(render, contains('refractColor.a = step(0.001, refractColor.a);'));
  });

  test('the light block needs a light or an ambient term', () {
    expect(
      render,
      contains(
        'if (edgeFactor > 0.01 && '
        '(uLightIntensity > 0.0 || uAmbientStrength > 0.0))',
      ),
    );
    // The touch glint inside scales by uLightIntensity, so skipping the block
    // at zero light loses nothing.
    expect(
      render,
      contains('tSpec * uTouchIntensity * uLightIntensity * 2.5'),
    );
  });

  test('a squircle with equal radii is evaluated once', () {
    final sdf = File('shaders/sdf.glsl').readAsStringSync();
    final asym = _body(sdf, 'float sdfSquircleAsym(');
    final shortcut = asym.indexOf('if (rTop == rBottom)');
    expect(shortcut, isNonNegative);
    expect(shortcut, lessThan(asym.indexOf('squircleShape(')));
    expect(asym, contains('return sdfSquircle(p, b, rTop);'));
  });
}
