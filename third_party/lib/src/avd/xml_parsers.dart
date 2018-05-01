import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

import '../utilities/xml.dart';
import '../svg/colors.dart';

const String androidNS = 'http://schemas.android.com/apk/res/android';

/// Parses an AVD @android:viewportWidth and @android:viewportHeight attributes to a [Rect].
Rect parseViewBox(XmlElement el) {
  final String rawWidth = getAttribute(el, 'viewportWidth', '', androidNS);
  final String rawHeight = getAttribute(el, 'viewportHeight', '', androidNS);
  if (rawWidth == '' || rawHeight == '') {
    return Rect.zero;
  }
  final double width = double.parse(rawWidth);
  final double height = double.parse(rawHeight);
  return new Rect.fromLTWH(0.0, 0.0, width, height);
}

Matrix4 parseTransform(XmlElement el) {
  double rotation = double.parse(getAttribute(el, 'rotation', '0', androidNS));
  double pivotX = double.parse(getAttribute(el, 'pivotX', '0', androidNS));
  double pivotY = double.parse(getAttribute(el, 'pivotY', '0', androidNS));
  double scaleX = double.parse(getAttribute(el, 'scaleX', '1', androidNS));
  double scaleY = double.parse(getAttribute(el, 'scaleY', '1', androidNS));
  double translateX =
      double.parse(getAttribute(el, 'translateX', '0', androidNS));
  double translateY =
      double.parse(getAttribute(el, 'translateY', '0', androidNS));

  return new Matrix4.identity()
    ..translate(pivotX, pivotY)
    ..rotateZ(rotation * pi / 180)
    ..scale(scaleX, scaleY)
    ..translate(-pivotX + translateX, -pivotY + translateY);
}

Paint parseStroke(XmlElement el, Rect bounds) {
  final String rawStroke = getAttribute(el, 'strokeColor', null, androidNS);
  if (rawStroke == null) {
    return null;
  }
  return new Paint()
    ..style = PaintingStyle.stroke
    ..color = parseColor(rawStroke)
        .withOpacity(double.parse(getAttribute(el, 'strokeAlpha', '1')))
    ..strokeWidth =
        double.parse(getAttribute(el, 'strokeWidth', '0', androidNS))
    ..strokeCap = parseStrokeCap(el)
    ..strokeJoin = parseStrokeJoin(el)
    ..strokeMiterLimit = parseMiterLimit(el);
}

double parseMiterLimit(XmlElement el) {
  return double.parse(getAttribute(el, 'strokeMiterLimit', '4', androidNS));
}

StrokeJoin parseStrokeJoin(XmlElement el) {
  final String rawStrokeJoin =
      getAttribute(el, 'strokeLineJoin', 'miter', androidNS);
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

StrokeCap parseStrokeCap(XmlElement el) {
  final String rawStrokeCap =
      getAttribute(el, 'strokeLineCap', 'butt', androidNS);
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

Paint parseFill(XmlElement el, Rect bounds) {
  final String rawFill = getAttribute(el, 'fillColor', null, androidNS);
  if (rawFill == null) {
    return null;
  }
  return new Paint()
    ..style = PaintingStyle.fill
    ..color = parseColor(rawFill)
        .withOpacity(double.parse(getAttribute(el, 'fillAlpha', '1')));
}

PathFillType parsePathFillType(XmlElement el) {
  final String rawFillType = getAttribute(el, 'fillType', 'nonZero', androidNS);
  return rawFillType == 'nonZero' ? PathFillType.nonZero : PathFillType.evenOdd;
}
