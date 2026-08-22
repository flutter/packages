// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

import 'shapes/shapes.dart';

/// Holds predefined Material Design shapes as [RoundedPolygon]s that can be
/// used at various components as they are, or as part of a [Morph].
///
/// Note that each [RoundedPolygon] in this class is normalized.
///
/// https://developer.android.com/images/reference/androidx/compose/material3/shapes.png
abstract final class MaterialShapes {
  static const _cornerRound15 = CornerRounding(radius: 0.15);
  static const _cornerRound20 = CornerRounding(radius: 0.2);
  static const _cornerRound30 = CornerRounding(radius: 0.3);
  static const _cornerRound50 = CornerRounding(radius: 0.5);
  static const _cornerRound100 = CornerRounding(radius: 1);

  static const double _negative45Radians = -45 * math.pi / 180;
  static const double _negative90Radians = -90 * math.pi / 180;
  static const double _negative135Radians = -135 * math.pi / 180;

  /// A circle shape.
  static final circle = RoundedPolygon.circle(
    numVertices: 10,
    radius: 0.5,
    centerX: 0.5,
    centerY: 0.5,
  );

  /// A square shape.
  static final square = RoundedPolygon.rectangle(
    width: 1,
    height: 1,
    rounding: _cornerRound30,
    centerX: 0.5,
    centerY: 0.5,
  );

  /// A slanted square shape.
  static final RoundedPolygon slanted = _customPolygon(const [
    _PointNRound(Point(0.926, 0.970), CornerRounding(radius: 0.189, smoothing: 0.811)),
    _PointNRound(Point(-0.021, 0.967), CornerRounding(radius: 0.187, smoothing: 0.057)),
  ], 2).normalized();

  /// An arch shape.
  static final RoundedPolygon arch =
      RoundedPolygon.fromVerticesNum(
            4,
            perVertexRounding: const [
              _cornerRound100,
              _cornerRound100,
              _cornerRound20,
              _cornerRound20,
            ],
          )
          .transformed((Matrix4.identity()..rotateZ(_negative135Radians)).asPointTransformer())
          .normalized();

  /// A semi-circle shape.
  static final RoundedPolygon semiCircle = RoundedPolygon.rectangle(
    width: 1.6,
    height: 1,
    perVertexRounding: const [_cornerRound20, _cornerRound20, _cornerRound100, _cornerRound100],
  ).normalized();

  /// An oval shape.
  static final RoundedPolygon oval = RoundedPolygon.circle()
      .transformed(
        (Matrix4.identity()
              ..rotateZ(_negative45Radians)
              ..scale(1.0, 0.64))
            .asPointTransformer(),
      )
      .normalized();

  /// An pill shape.
  static final RoundedPolygon pill = _customPolygon(
    [
      const _PointNRound(Point(0.961, 0.039), CornerRounding(radius: 0.426)),
      const _PointNRound(Point(1.001, 0.428)),
      const _PointNRound(Point(1, 0.609), CornerRounding(radius: 1)),
    ],
    2,
    mirroring: true,
  ).normalized();

  /// A triangle shape.
  static final RoundedPolygon triangle = RoundedPolygon.fromVerticesNum(3, rounding: _cornerRound20)
      .transformed((Matrix4.identity()..rotateZ(_negative90Radians)).asPointTransformer())
      .normalized();

  /// An arrow shape.
  static final RoundedPolygon arrow = _customPolygon([
    const _PointNRound(Point(0.5, 0.892), CornerRounding(radius: 0.313)),
    const _PointNRound(Point(-0.216, 1.05), CornerRounding(radius: 0.207)),
    const _PointNRound(Point(0.499, -0.16), CornerRounding(radius: 0.215, smoothing: 1)),
    const _PointNRound(Point(1.225, 1.06), CornerRounding(radius: 0.211)),
  ], 1).normalized();

  /// A fan shape.
  static final RoundedPolygon fan = _customPolygon([
    const _PointNRound(Point(1.004, 1), CornerRounding(radius: 0.148, smoothing: 0.417)),
    const _PointNRound(Point(0, 1), CornerRounding(radius: 0.151)),
    const _PointNRound(Point(0, -0.003), CornerRounding(radius: 0.148)),
    const _PointNRound(Point(0.978, 0.02), CornerRounding(radius: 0.803)),
  ], 1).normalized();

  /// A diamond shape.
  static final RoundedPolygon diamond = _customPolygon([
    const _PointNRound(Point(0.5, 1.096), CornerRounding(radius: 0.151, smoothing: 0.524)),
    const _PointNRound(Point(0.04, 0.5), CornerRounding(radius: .159)),
  ], 2).normalized();

  /// A clam-shell shape.
  static final RoundedPolygon clamShell = _customPolygon([
    const _PointNRound(Point(0.171, 0.841), CornerRounding(radius: 0.159)),
    const _PointNRound(Point(-0.02, 0.5), CornerRounding(radius: 0.140)),
    const _PointNRound(Point(0.17, 0.159), CornerRounding(radius: 0.159)),
  ], 2).normalized();

  /// A pentagon shape.
  static final RoundedPolygon pentagon = _customPolygon(
    [
      const _PointNRound(Point(0.5, -0.009), CornerRounding(radius: 0.172)),
      const _PointNRound(Point(1.03, 0.365), CornerRounding(radius: 0.164)),
      const _PointNRound(Point(0.828, 0.97), CornerRounding(radius: 0.169)),
    ],
    1,
    mirroring: true,
  ).normalized();

  /// A gem shape.
  static final RoundedPolygon gem = _customPolygon(
    [
      const _PointNRound(Point(0.499, 1.023), CornerRounding(radius: 0.241, smoothing: 0.778)),
      const _PointNRound(Point(-0.005, 0.792), CornerRounding(radius: 0.208)),
      const _PointNRound(Point(0.073, 0.258), CornerRounding(radius: 0.228)),
      const _PointNRound(Point(0.433, -0), CornerRounding(radius: 0.491)),
    ],
    1,
    mirroring: true,
  ).normalized();

  /// A sunny shape.
  static final RoundedPolygon sunny = RoundedPolygon.star(
    numVerticesPerRadius: 8,
    innerRadius: 0.8,
    rounding: _cornerRound15,
  ).normalized();

  /// A very-sunny shape.
  static final RoundedPolygon verySunny = _customPolygon([
    const _PointNRound(Point(0.5, 1.080), CornerRounding(radius: 0.085)),
    const _PointNRound(Point(0.358, 0.843), CornerRounding(radius: 0.085)),
  ], 8).normalized();

  /// A 4-sided cookie shape.
  static final RoundedPolygon cookie4Sided = _customPolygon([
    const _PointNRound(Point(1.237, 1.236), CornerRounding(radius: 0.258)),
    const _PointNRound(Point(0.5, 0.918), CornerRounding(radius: 0.233)),
  ], 4).normalized();

  /// A 6-sided cookie shape.
  static final RoundedPolygon cookie6Sided = _customPolygon([
    const _PointNRound(Point(0.723, 0.884), CornerRounding(radius: 0.394)),
    const _PointNRound(Point(0.5, 1.099), CornerRounding(radius: 0.398)),
  ], 6).normalized();

  /// A 7-sided cookie shape.
  static final RoundedPolygon cookie7Sided =
      RoundedPolygon.star(numVerticesPerRadius: 7, innerRadius: 0.75, rounding: _cornerRound50)
          .transformed((Matrix4.identity()..rotateZ(_negative90Radians)).asPointTransformer())
          .normalized();

  /// A 9-sided cookie shape.
  static final RoundedPolygon cookie9Sided =
      RoundedPolygon.star(numVerticesPerRadius: 9, innerRadius: 0.8, rounding: _cornerRound50)
          .transformed((Matrix4.identity()..rotateZ(_negative90Radians)).asPointTransformer())
          .normalized();

  /// A 12-sided cookie shape.
  static final RoundedPolygon cookie12Sided =
      RoundedPolygon.star(numVerticesPerRadius: 12, innerRadius: 0.8, rounding: _cornerRound50)
          .transformed((Matrix4.identity()..rotateZ(_negative90Radians)).asPointTransformer())
          .normalized();

  /// A 4-leaf clover shape.
  static final RoundedPolygon clover4Leaf = _customPolygon(
    [
      const _PointNRound(Point(0.5, 0.074)),
      const _PointNRound(Point(0.725, -0.099), CornerRounding(radius: 0.476)),
    ],
    4,
    mirroring: true,
  ).normalized();

  /// A 8-leaf clover shape.
  static final RoundedPolygon clover8Leaf = _customPolygon([
    const _PointNRound(Point(0.5, 0.036)),
    const _PointNRound(Point(0.758, -0.101), CornerRounding(radius: 0.209)),
  ], 8).normalized();

  /// A burst shape.
  static final RoundedPolygon burst = _customPolygon([
    const _PointNRound(Point(0.5, -0.006), CornerRounding(radius: 0.006)),
    const _PointNRound(Point(0.592, 0.158), CornerRounding(radius: 0.006)),
  ], 12).normalized();

  /// A soft-burst shape.
  static final RoundedPolygon softBurst = _customPolygon([
    const _PointNRound(Point(0.193, 0.277), CornerRounding(radius: 0.053)),
    const _PointNRound(Point(0.176, 0.055), CornerRounding(radius: 0.053)),
  ], 10).normalized();

  /// A boom shape.
  static final RoundedPolygon boom = _customPolygon([
    const _PointNRound(Point(0.457, 0.296), CornerRounding(radius: 0.007)),
    const _PointNRound(Point(0.5, -0.051), CornerRounding(radius: 0.007)),
  ], 15).normalized();

  /// A soft-boom shape.
  static final RoundedPolygon softBoom = _customPolygon(
    [
      const _PointNRound(Point(0.733, 0.454)),
      const _PointNRound(Point(0.839, 0.437), CornerRounding(radius: 0.532)),
      const _PointNRound(Point(0.949, 0.449), CornerRounding(radius: 0.439, smoothing: 1)),
      const _PointNRound(Point(0.998, 0.478), CornerRounding(radius: 0.174)),
    ],
    16,
    mirroring: true,
  ).normalized();

  /// A flower shape.
  static final RoundedPolygon flower = _customPolygon(
    [
      const _PointNRound(Point(0.370, 0.187)),
      const _PointNRound(Point(0.416, 0.049), CornerRounding(radius: 0.381)),
      const _PointNRound(Point(0.479, 0.001), CornerRounding(radius: 0.095)),
    ],
    8,
    mirroring: true,
  ).normalized();

  /// A puffy shape.
  static final RoundedPolygon puffy = _customPolygon(
    [
      const _PointNRound(Point(0.5, 0.053)),
      const _PointNRound(Point(0.545, -0.04), CornerRounding(radius: 0.405)),
      const _PointNRound(Point(0.670, -0.035), CornerRounding(radius: 0.426)),
      const _PointNRound(Point(0.717, 0.066), CornerRounding(radius: 0.574)),
      const _PointNRound(Point(0.722, 0.128)),
      const _PointNRound(Point(0.777, 0.002), CornerRounding(radius: 0.36)),
      const _PointNRound(Point(0.914, 0.149), CornerRounding(radius: 0.66)),
      const _PointNRound(Point(0.926, 0.289), CornerRounding(radius: 0.66)),
      const _PointNRound(Point(0.881, 0.346)),
      const _PointNRound(Point(0.940, 0.344), CornerRounding(radius: 0.126)),
      const _PointNRound(Point(1.003, 0.437), CornerRounding(radius: 0.255)),
    ],
    2,
    mirroring: true,
  ).transformed((Matrix4.identity()..scale(1.0, 0.742)).asPointTransformer()).normalized();

  /// A puffy-diamond shape.
  static final RoundedPolygon puffyDiamond = _customPolygon(
    [
      const _PointNRound(Point(0.87, 0.13), CornerRounding(radius: 0.146)),
      const _PointNRound(Point(0.818, 0.357)),
      const _PointNRound(Point(1, 0.332), CornerRounding(radius: 0.853)),
    ],
    4,
    mirroring: true,
  ).normalized();

  /// A ghostish shape.
  static final RoundedPolygon ghostish = _customPolygon(
    [
      const _PointNRound(Point(0.5, 0), CornerRounding(radius: 1)),
      const _PointNRound(Point(1, 0), CornerRounding(radius: 1)),
      const _PointNRound(Point(1, 1.14), CornerRounding(radius: 0.254, smoothing: 0.106)),
      const _PointNRound(Point(0.575, 0.906), CornerRounding(radius: 0.253)),
    ],
    1,
    mirroring: true,
  ).normalized();

  /// A pixel-circle shape.
  static final RoundedPolygon pixelCircle = _customPolygon(
    [
      const _PointNRound(Point(0.5, 0)),
      const _PointNRound(Point(0.704, 0)),
      const _PointNRound(Point(0.704, 0.065)),
      const _PointNRound(Point(0.843, 0.065)),
      const _PointNRound(Point(0.843, 0.148)),
      const _PointNRound(Point(0.926, 0.148)),
      const _PointNRound(Point(0.926, 0.296)),
      const _PointNRound(Point(1, 0.296)),
    ],
    2,
    mirroring: true,
  ).normalized();

  /// A pixel-triangle shape.
  static final RoundedPolygon pixelTriangle = _customPolygon(
    [
      const _PointNRound(Point(0.11, 0.5)),
      const _PointNRound(Point(0.113, 0)),
      const _PointNRound(Point(0.287, 0)),
      const _PointNRound(Point(0.287, 0.087)),
      const _PointNRound(Point(0.421, 0.087)),
      const _PointNRound(Point(0.421, 0.17)),
      const _PointNRound(Point(0.56, 0.17)),
      const _PointNRound(Point(0.56, 0.265)),
      const _PointNRound(Point(0.674, 0.265)),
      const _PointNRound(Point(0.675, 0.344)),
      const _PointNRound(Point(0.789, 0.344)),
      const _PointNRound(Point(0.789, 0.439)),
      const _PointNRound(Point(0.888, 0.439)),
    ],
    1,
    mirroring: true,
  ).normalized();

  /// A bun shape.
  static final RoundedPolygon bun = _customPolygon(
    [
      const _PointNRound(Point(0.796, 0.5)),
      const _PointNRound(Point(0.853, 0.518), CornerRounding(radius: 1)),
      const _PointNRound(Point(0.992, 0.631), CornerRounding(radius: 1)),
      const _PointNRound(Point(0.968, 1), CornerRounding(radius: 1)),
    ],
    2,
    mirroring: true,
  ).normalized();

  /// A heart shape.
  static final RoundedPolygon heart = _customPolygon(
    [
      const _PointNRound(Point(0.5, 0.268), CornerRounding(radius: 0.016)),
      const _PointNRound(Point(0.792, -0.066), CornerRounding(radius: 0.958)),
      const _PointNRound(Point(1.064, 0.276), CornerRounding(radius: 1)),
      const _PointNRound(Point(0.501, 0.946), CornerRounding(radius: 0.129)),
    ],
    1,
    mirroring: true,
  ).normalized();

  /// A list of all available shapes.
  static final UnmodifiableListView<RoundedPolygon> all = UnmodifiableListView(<RoundedPolygon>[
    MaterialShapes.circle,
    MaterialShapes.square,
    MaterialShapes.slanted,
    MaterialShapes.arch,
    MaterialShapes.semiCircle,
    MaterialShapes.oval,
    MaterialShapes.pill,
    MaterialShapes.triangle,
    MaterialShapes.arrow,
    MaterialShapes.fan,
    MaterialShapes.diamond,
    MaterialShapes.clamShell,
    MaterialShapes.pentagon,
    MaterialShapes.gem,
    MaterialShapes.sunny,
    MaterialShapes.verySunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.cookie6Sided,
    MaterialShapes.cookie7Sided,
    MaterialShapes.cookie9Sided,
    MaterialShapes.cookie12Sided,
    MaterialShapes.clover4Leaf,
    MaterialShapes.clover8Leaf,
    MaterialShapes.burst,
    MaterialShapes.softBurst,
    MaterialShapes.boom,
    MaterialShapes.softBoom,
    MaterialShapes.flower,
    MaterialShapes.puffy,
    MaterialShapes.puffyDiamond,
    MaterialShapes.ghostish,
    MaterialShapes.pixelCircle,
    MaterialShapes.pixelTriangle,
    MaterialShapes.bun,
    MaterialShapes.heart,
  ]);

  static RoundedPolygon _customPolygon(
    List<_PointNRound> pnr,
    int reps, {
    Point center = const Point(0.5, 0.5),
    bool mirroring = false,
  }) {
    final List<_PointNRound> actualPoints = _doRepeat(pnr, reps, center, mirroring);

    final vertices = List<double>.filled(actualPoints.length * 2, 0);
    final perVertexRounding = List<CornerRounding>.filled(
      actualPoints.length,
      CornerRounding.unrounded,
    );

    for (var i = 0; i < actualPoints.length; i++) {
      final _PointNRound ap = actualPoints[i];
      perVertexRounding[i] = ap.r;

      final int j = i * 2;
      vertices[j] = ap.p.x;
      vertices[j + 1] = ap.p.y;
    }

    return RoundedPolygon.fromVertices(
      vertices,
      perVertexRounding: perVertexRounding,
      centerX: center.x,
      centerY: center.y,
    );
  }

  static List<_PointNRound> _doRepeat(
    List<_PointNRound> points,
    int reps,
    Point center,
    bool mirroring,
  ) {
    final result = <_PointNRound>[];

    if (mirroring) {
      final List<({double angle, double distance})> measures = List.generate(points.length, (i) {
        final _PointNRound point = points[i];
        final Point off = point.p - center;
        return (angle: off.angleRadians, distance: off.getDistance());
      });
      final int actualReps = reps * 2;
      final double sectionAngle = math.pi * 2 / actualReps;

      for (var r = 0; r < actualReps; r++) {
        for (var index = 0; index < points.length; index++) {
          final int i = (r.isEven) ? index : points.length - 1 - index;
          if (i > 0 || r.isEven) {
            final double a =
                sectionAngle * r +
                ((r.isEven)
                    ? measures[i].angle
                    : sectionAngle - measures[i].angle + 2 * measures[0].angle);

            final Point finalPoint =
                Point(math.cos(a), math.sin(a)) * measures[i].distance + center;

            result.add(_PointNRound(finalPoint, points[i].r));
          }
        }
      }
    } else {
      final int np = points.length;
      for (var i = 0; i < np * reps; i++) {
        final Point point = points[i % np].p.rotate((i ~/ np) * 360 / reps, center: center);
        result.add(_PointNRound(point, points[i % np].r));
      }
    }

    return result;
  }
}

class _PointNRound {
  const _PointNRound(this.p, [this.r = CornerRounding.unrounded]);

  final Point p;

  final CornerRounding r;
}
