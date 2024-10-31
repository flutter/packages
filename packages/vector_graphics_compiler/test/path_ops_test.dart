// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/_initialize_path_ops_io.dart'
    as vector_graphics;
import 'package:vector_graphics_compiler/src/svg/path_ops.dart';

void main() {
  setUpAll(() {
    if (!vector_graphics.initializePathOpsFromFlutterCache()) {
      fail('error in setup');
    }
  });
  test('Path tests', () {
    final Path path = Path()
      ..lineTo(10, 0)
      ..lineTo(10, 10)
      ..lineTo(0, 10)
      ..close()
      ..cubicTo(30, 30, 40, 40, 50, 50);

    expect(path.fillType, FillType.nonZero);
    expect(path.verbs.toList(), <PathVerb>[
      PathVerb.moveTo, // Skia inserts a moveTo here.
      PathVerb.lineTo,
      PathVerb.lineTo,
      PathVerb.lineTo,
      PathVerb.close,
      PathVerb.moveTo, // Skia inserts a moveTo here.
      PathVerb.cubicTo,
    ]);
    expect(path.points,
        <double>[0, 0, 10, 0, 10, 10, 0, 10, 0, 0, 30, 30, 40, 40, 50, 50]);

    final SvgPathProxy proxy = SvgPathProxy();
    path.replay(proxy);
    expect(proxy.toString(),
        'M0.0,0.0L10.0,0.0L10.0,10.0L0.0,10.0ZM0.0,0.0C30.0,30.0 40.0,40.0 50.0,50.0');
    path.dispose();
  });

  test('Ops test', () {
    final Path cubics = Path()
      ..moveTo(16, 128)
      ..cubicTo(16, 66, 66, 16, 128, 16)
      ..cubicTo(240, 66, 16, 66, 240, 128)
      ..close();

    final Path quad = Path()
      ..moveTo(55, 16)
      ..lineTo(200, 80)
      ..lineTo(198, 230)
      ..lineTo(15, 230)
      ..close();

    final Path intersection = cubics.applyOp(quad, PathOp.intersect);

    expect(intersection.verbs, <PathVerb>[
      PathVerb.moveTo,
      PathVerb.lineTo,
      PathVerb.cubicTo,
      PathVerb.lineTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.lineTo,
      PathVerb.lineTo,
      PathVerb.close
    ]);
    expect(intersection.points, <double>[
      34.06542205810547, 128.0, // move
      48.90797424316406, 48.59233856201172, // line
      57.80497360229492, 39.73065185546875, 68.189697265625, 32.3614387512207,
      79.66168212890625, 26.885154724121094, // cubic
      151.7936248779297, 58.72270584106445, // line
      150.66123962402344, 59.74142837524414, 149.49365234375,
      60.752471923828125, 148.32867431640625, 61.76123809814453, // cubic
      132.3506317138672, 75.59684753417969, 116.86703491210938,
      89.0042953491211, 199.52090454101562, 115.93260192871094, // cubic
      199.36000061035156, 128.0, // line
      34.06542205810547, 128.0, // line
      // close
    ]);
    cubics.dispose();
    quad.dispose();
    intersection.dispose();
  });

  test('Quad', () {
    final Path top = Path()
      ..moveTo(87.998, 103.591)
      ..lineTo(82.72, 103.591)
      ..lineTo(82.72, 106.64999999999999)
      ..lineTo(87.998, 106.64999999999999)
      ..lineTo(87.998, 103.591)
      ..close();

    final Path bottom = Path()
      ..moveTo(116.232, 154.452)
      ..lineTo(19.031999999999996, 154.452)
      ..cubicTo(18.671999999999997, 142.112, 21.361999999999995,
          132.59199999999998, 26.101999999999997, 125.372)
      ..cubicTo(32.552, 115.55199999999999, 42.782, 110.012, 54.30199999999999,
          107.502)
      ..cubicTo(56.931999185062395, 106.9278703703336, 59.593157782987156,
          106.50716022812718, 62.27200212186002, 106.24200362009655)
      ..lineTo(62.291999999999994, 106.24199999999999)
      ..cubicTo(67.10118331429277, 105.77278829340533, 71.940772522921,
          105.69920780785604, 76.76199850891219, 106.021997940542)
      ..cubicTo(78.762, 106.142, 80.749, 106.32199999999999, 82.722, 106.562)
      ..lineTo(83.362, 106.652)
      ..cubicTo(84.112, 106.742, 84.85199999999999, 106.852, 85.592, 106.972)
      ..cubicTo(86.852, 107.152, 88.102, 107.372, 89.342, 107.60199999999999)
      ..cubicTo(89.542, 107.642, 89.732, 107.67199999999998, 89.922,
          107.71199999999999)
      ..cubicTo(91.54899999999999, 108.02599999999998, 93.14, 108.502, 94.672,
          109.13199999999999)
      ..cubicTo(98.35184786478965, 110.61003782601773, 101.5939983878398,
          113.00207032444644, 104.09199525642647, 116.08199471003054)
      ..cubicTo(104.181, 116.17999999999999, 104.264, 116.28399999999999,
          104.342, 116.392)
      ..cubicTo(104.512, 116.612, 104.682, 116.832, 104.842, 117.062)
      ..cubicTo(105.102, 117.41199999999999, 105.352, 117.77199999999999,
          105.592, 118.142)
      ..cubicTo(107.63018430068513, 121.33505319707416, 109.25008660688327,
          124.77650539945358, 110.41200699229772, 128.38200813032248)
      ..cubicTo(112.762, 135.252, 114.50200000000001, 143.862, 116.232, 154.452)
      ..close();

    final Path intersect = bottom.applyOp(top, PathOp.intersect);
    // current revision of Skia makes this result in a quad verb getting used.
    final Path difference = bottom.applyOp(intersect, PathOp.difference);

    expect(difference.verbs.toList(), <PathVerb>[
      PathVerb.moveTo,
      PathVerb.lineTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.quadTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.lineTo,
      PathVerb.lineTo,
      PathVerb.lineTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.lineTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.cubicTo,
      PathVerb.close,
    ]);
  });
}
