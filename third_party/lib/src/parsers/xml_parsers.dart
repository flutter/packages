import 'dart:ui';

import 'package:flutter_svg/src/parsers/colors.dart';
import 'package:xml/xml.dart';

Paint parseStroke(XmlElement el) {
  final rawStroke = el.getAttribute('stroke');
  if (rawStroke == null || rawStroke.length == 0) {
    return null;
  }

  var rawOpacity = el.getAttribute('stroke-opacity');
  if (rawOpacity == null) {
    rawOpacity = el.getAttribute('opacity');
  }
  final opacity = rawOpacity == null
      ? 255
      : (double.parse(rawOpacity, (source) => 1.0).clamp(0.0, 1.0) * 255)
          .toInt();
  final stroke = parseColor(rawStroke).withAlpha(opacity);

  final rawStrokeCap = el.getAttribute('stroke-linecap');
  StrokeCap strokeCap = rawStrokeCap == null
      ? StrokeCap.butt
      : StrokeCap.values.firstWhere(
          (sc) => sc.toString() == 'StrokeCap.$rawStrokeCap',
          orElse: () => StrokeCap.butt);

  final rawLineJoin = el.getAttribute('stroke-linejoin');
  StrokeJoin strokeJoin = rawLineJoin == null
      ? StrokeJoin.miter
      : StrokeJoin.values.firstWhere(
          (sj) => sj.toString() == 'StrokeJoin.$rawLineJoin',
          orElse: () => StrokeJoin.miter);

  final rawMiterLimit = el.getAttribute('stroke-miterlimit');
  final miterLimit = rawMiterLimit == null ? 4.0 : double.parse(rawMiterLimit);

  final rawStrokeWidth = el.getAttribute('stroke-width');
  final strokeWidth =
      rawStrokeWidth == null ? 1.0 : double.parse(rawStrokeWidth);

  // TODO: Dash patterns not currently supported
  if (el.getAttribute('stroke-dashoffset') != null ||
      el.getAttribute('stroke-dasharray') != null) {
    print('Warning: Dash patterns not currently supported');
  }
  
  return new Paint()
    ..color = stroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
    ..strokeMiterLimit = miterLimit;
}

Paint parseFill(XmlElement el, {bool isShape = true}) {
  final rawFill = el.getAttribute('fill');
  if (rawFill == null || rawFill.length == 0) {
    if (isShape) {
      return new Paint()
        ..color = colorBlack
        ..style = PaintingStyle.fill;
    } else {
      return null;
    }
  }

  var rawOpacity = el.getAttribute('fill-opacity');
  if (rawOpacity == null) {
    rawOpacity = el.getAttribute('opacity');
  }
  final opacity = rawOpacity == null
      ? 255
      : (double.parse(rawOpacity, (source) => 1.0).clamp(0.0, 1.0) * 255)
          .toInt();
  final fill = parseColor(rawFill).withAlpha(opacity);

  return new Paint()
    ..color = fill
    ..style = PaintingStyle.fill;
}
