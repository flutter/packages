import 'dart:ui';

import 'package:flutter_svg/src/parsers/colors.dart';
import 'package:xml/xml.dart';

Paint parseStroke(XmlElement el) {
  final rawStroke = el.getAttribute('stroke');
  if (rawStroke == null || rawStroke.length == 0) {
    return new Paint()..color = colorBlack;
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

  // TODO: stroke types
  return new Paint()
    ..color = stroke
    ..style = PaintingStyle.stroke;
}

Paint parseFill(XmlElement el) {
  final rawFill = el.getAttribute('fill');
  if (rawFill == null || rawFill.length == 0) {
    return new Paint()..color = colorBlack;
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
