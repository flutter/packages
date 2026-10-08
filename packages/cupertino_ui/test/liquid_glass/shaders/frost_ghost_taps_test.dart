// The frost's ghost at the floor sigma takes 6 taps instead of 45.
//
// uFrost.z is 0 whenever the blur runs as a pass of its own or is 0, and the
// shader clamps the sigma to 0.3 px. At that sigma only the three columns
// around the sample on the two even rows either side of it carry weight, so
// the shader reads those 6 and skips the other 39.
//
// The shader can't run under `flutter test` (Skia), so this checks the source
// for the branch, and checks the arithmetic with the shader's own weights in
// Dart: the 6 taps come out within a fraction of 1/255 of all 45, with the
// luminance weighting at its extremes and the worst texels a frame can hold.

import 'dart:io';
import 'dart:math' as math;

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

/// The ghost of the shader's loop over columns [columns] (offsets from the
/// centre column) and even rows [rows] (offsets in steps of 2 px), for a
/// sample at fraction [fx] of its pixel and [fy] above the even row, with
/// every texel black except [white] (true: in the kept taps).
double _ghost({
  required Iterable<int> columns,
  required Iterable<int> rows,
  required double fx,
  required double fy,
  required double blurWeight,
  required bool Function(int column, int row) white,
}) {
  const sigma = 0.3;
  const inv2s2 = 1 / (2 * sigma * sigma);
  final slope = blurWeight - 1;
  var acc = 0.0;
  var wsum = 0.0;
  for (final j in rows) {
    final dy = 2.0 * j + 0.5 - fy;
    final wy = math.exp(-dy * dy * inv2s2);
    for (final i in columns) {
      final dx = i + 0.5 - fx;
      final c = white(i, j) ? 1.0 : 0.0;
      final w = wy * math.exp(-dx * dx * inv2s2) * (1 + slope * c);
      acc += w * c;
      wsum += w;
    }
  }
  return acc / wsum;
}

void main() {
  final render = File('shaders/liquid_glass_render.frag').readAsStringSync();

  test('the floor sigma reads 6 taps, everything else all 45', () {
    final frostAt = _body(render, 'vec3 frostAt(');
    final gate = frostAt.indexOf('if (uFrost.z <= 0.3)');
    final full = frostAt.indexOf('for (int j = -2; j <= 2; j++)');
    expect(gate, isNonNegative, reason: 'The 6-tap branch is gone.');
    expect(gate, lessThan(full));
    final small = frostAt.substring(gate, full);
    expect(small, contains('for (int j = 0; j <= 1; j++)'));
    expect(small, contains('for (int i = 3; i <= 5; i++)'));
    // The same taps with the same weights as the full loop.
    expect(small, contains('float x = base.x + float(i - 4);'));
    expect(small, contains('* (1.0 + slope * dot(c, LUMA_WEIGHTS));'));
    // The floor the gate relies on.
    expect(frostAt, contains('float sigma = max(uFrost.z, 0.3);'));
  });

  test('the 6 taps match the 45 within 0.05/255', () {
    const all = [-4, -3, -2, -1, 0, 1, 2, 3, 4];
    const allRows = [-2, -1, 0, 1, 2];
    const kept = [-1, 0, 1];
    const keptRows = [0, 1];
    var worst = 0.0;
    for (final blurWeight in [0.5, 0.8, 1.0, 2.5, 4.0]) {
      for (var a = 0; a < 50; a++) {
        final fx = a / 50;
        for (var b = 0; b < 100; b++) {
          final fy = b / 50;
          // The worst a frame can do: the kept taps one extreme, the
          // skipped ones the other.
          for (final keptWhite in [true, false]) {
            bool white(int i, int j) =>
                (kept.contains(i) && keptRows.contains(j)) == keptWhite;
            final full = _ghost(
              columns: all,
              rows: allRows,
              fx: fx,
              fy: fy,
              blurWeight: blurWeight,
              white: white,
            );
            final six = _ghost(
              columns: kept,
              rows: keptRows,
              fx: fx,
              fy: fy,
              blurWeight: blurWeight,
              white: white,
            );
            worst = math.max(worst, (full - six).abs());
          }
        }
      }
    }
    expect(worst * 255, lessThan(0.05));
  });
}
