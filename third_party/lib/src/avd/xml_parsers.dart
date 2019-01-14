// ignore_for_file: public_member_api_docs
import 'dart:math';
import 'dart:ui';

import 'package:flutter_svg/src/vector_drawable.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

import '../svg/colors.dart';
import '../utilities/xml.dart';

/// The AVD namespace.
const String androidNS = 'http://schemas.android.com/apk/res/android';

/// Parses an AVD @android:viewportWidth and @android:viewportHeight attributes to a [Rect].
DrawableViewport parseViewBox(List<XmlAttribute> el) {
  final String rawWidth =
      getAttribute(el, 'viewportWidth', def: '', namespace: androidNS);
  final String rawHeight =
      getAttribute(el, 'viewportHeight', def: '', namespace: androidNS);
  if (rawWidth == '' || rawHeight == '') {
    return const DrawableViewport(Size.zero, Size.zero);
  }
  final double width = double.parse(rawWidth);
  final double height = double.parse(rawHeight);
  return DrawableViewport(
    Size(width, height),
    Size(width, height),
  );
}

Matrix4 parseTransform(List<XmlAttribute> el) {
  final double rotation = double.parse(
      getAttribute(el, 'rotation', def: '0', namespace: androidNS));
  final double pivotX =
      double.parse(getAttribute(el, 'pivotX', def: '0', namespace: androidNS));
  final double pivotY =
      double.parse(getAttribute(el, 'pivotY', def: '0', namespace: androidNS));
  final double scaleX =
      double.parse(getAttribute(el, 'scaleX', def: '1', namespace: androidNS));
  final double scaleY =
      double.parse(getAttribute(el, 'scaleY', def: '1', namespace: androidNS));
  final double translateX = double.parse(
      getAttribute(el, 'translateX', def: '0', namespace: androidNS));
  final double translateY = double.parse(
      getAttribute(el, 'translateY', def: '0', namespace: androidNS));

  return Matrix4.identity()
    ..translate(pivotX, pivotY)
    ..rotateZ(rotation * pi / 180)
    ..scale(scaleX, scaleY)
    ..translate(-pivotX + translateX, -pivotY + translateY);
}

DrawablePaint parseStroke(List<XmlAttribute> el, Rect bounds) {
  final String rawStroke =
      getAttribute(el, 'strokeColor', def: null, namespace: androidNS);
  if (rawStroke == null) {
    return null;
  }
  return DrawablePaint(
    PaintingStyle.stroke,
    color: parseColor(rawStroke).withOpacity(double.parse(
        getAttribute(el, 'strokeAlpha', def: '1', namespace: androidNS))),
    strokeWidth: double.parse(
        getAttribute(el, 'strokeWidth', def: '0', namespace: androidNS)),
    strokeCap: parseStrokeCap(el),
    strokeJoin: parseStrokeJoin(el),
    strokeMiterLimit: parseMiterLimit(el),
  );
}

double parseMiterLimit(List<XmlAttribute> el) {
  return double.parse(
      getAttribute(el, 'strokeMiterLimit', def: '4', namespace: androidNS));
}

StrokeJoin parseStrokeJoin(List<XmlAttribute> el) {
  final String rawStrokeJoin =
      getAttribute(el, 'strokeLineJoin', def: 'miter', namespace: androidNS);
  switch (rawStrokeJoin) {
    case 'miter':
      return StrokeJoin.miter;
    case 'bevel':
      return StrokeJoin.bevel;
    case 'round':
      return StrokeJoin.round;
    default:
      return StrokeJoin.miter;
  }
}

StrokeCap parseStrokeCap(List<XmlAttribute> el) {
  final String rawStrokeCap =
      getAttribute(el, 'strokeLineCap', def: 'butt', namespace: androidNS);
  switch (rawStrokeCap) {
    case 'butt':
      return StrokeCap.butt;
    case 'round':
      return StrokeCap.round;
    case 'square':
      return StrokeCap.square;
    default:
      return StrokeCap.butt;
  }
}

DrawablePaint parseFill(List<XmlAttribute> el, Rect bounds) {
  final String rawFill =
      getAttribute(el, 'fillColor', def: null, namespace: androidNS);
  if (rawFill == null) {
    return null;
  }
  return DrawablePaint(
    PaintingStyle.fill,
    color: parseColor(rawFill)
        .withOpacity(double.parse(getAttribute(el, 'fillAlpha', def: '1'))),
  );
}

PathFillType parsePathFillType(List<XmlAttribute> el) {
  final String rawFillType =
      getAttribute(el, 'fillType', def: 'nonZero', namespace: androidNS);
  return rawFillType == 'nonZero' ? PathFillType.nonZero : PathFillType.evenOdd;
}
