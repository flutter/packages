import 'dart:ui';

import 'package:xml/xml.dart';

import '../vector_painter.dart';
import 'colors.dart';

/// Parses an SVG @viewBox attribute (e.g. 0 0 100 100) to a [Rect].
Rect parseViewBox(XmlElement svg) {
  final String viewBox = _getAttribute(svg, 'viewBox');

  if (viewBox == '') {
    final RegExp notDigits = new RegExp(r'[^\d\.]');
    final String rawWidth =
        _getAttribute(svg, 'width').replaceAll(notDigits, '');
    final String rawHeight =
        _getAttribute(svg, 'height').replaceAll(notDigits, '');
    if (rawWidth == '' || rawHeight == '') {
      return Rect.zero;
    }
    final double width = double.parse(rawWidth);
    final double height = double.parse(rawHeight);
    return new Rect.fromLTWH(0.0, 0.0, width, height);
  }

  final parts = viewBox.split(new RegExp(r'[ ,]+'));
  if (parts.length < 4) {
    throw new StateError('viewBox element must be 4 elements long');
  }
  return new Rect.fromLTWH(
    double.parse(parts[0]),
    double.parse(parts[1]),
    double.parse(parts[2]),
    double.parse(parts[3]),
  );
}

/// Parses a <def> element, extracting <linearGradient> and (TODO) <radialGradient> elements into the `paintServers` map.
void parseDefs(
    XmlElement el, Map<String, PaintServer> paintServers, Size size) {
  el.children.forEach((XmlNode def) {
    if (def is XmlElement) {
      if (def.name.local.endsWith('Gradient')) {
        paintServers['url(#${def.getAttribute('id')})'] =
            (size) => parseGradient(def, size);
      }
    }
  });
}

/// Gets the attribute, trims it, and returns the attribute or default if the attribute
/// is null or ''.
String _getAttribute(XmlElement el, String name, [String def = '']) {
  final String raw = el.getAttribute(name)?.trim();
  return raw == '' || raw == null ? def : raw;
}

double _parseDecimalOrPercentage(String val) {
  if (val.endsWith('%')) {
    return double.parse(val.substring(0, val.length - 1)) / 100;
  } else {
    return double.parse(val);
  }
}

/// Parses an SVG <linearGradient> element into a [Paint].
Paint parseLinearGradient(XmlElement el, Size size) {
  final double x1 = _parseDecimalOrPercentage(_getAttribute(el, 'x1', '0%'));
  final double x2 = _parseDecimalOrPercentage(_getAttribute(el, 'x2', '100%'));
  final double y1 = _parseDecimalOrPercentage(_getAttribute(el, 'y1', '0%'));
  final double y2 = _parseDecimalOrPercentage(_getAttribute(el, 'y2', '0%'));

  final Offset from = new Offset(size.width * x1, size.height * y1);
  final Offset to = new Offset(size.width * x2, size.height * y2);
  final stops = el.findElements('stop').toList();
  final Gradient gradient = new Gradient.linear(
    from,
    to,
    stops.map((stop) {
      final String rawOpacity = _getAttribute(stop, 'stop-opacity', '1');
      return parseColor(_getAttribute(stop, 'stop-color'))
          .withOpacity(double.parse(rawOpacity));
    }).toList(),
    stops.map((stop) {
      final String rawOffset = _getAttribute(stop, 'offset');
      return _parseDecimalOrPercentage(rawOffset);
    }).toList(),
  );

  return new Paint()..shader = gradient;
}

/// Parses a <linearGradient> or <radialGradient> into a [Paint].
Paint parseGradient(XmlElement el, Size size) {
  if (el.name.local == 'linearGradient') {
    return parseLinearGradient(el, size);
  } else if (el.name.local == 'radialGradient') {
    return new Paint()..color = new Color(0xFFABCDEF);
  }
  throw new StateError('Unknown gradient type ${el.name.local}');
}

/// Parses a @stroke attribute into a [Paint].
Paint parseStroke(
    XmlElement el, Size size, Map<String, PaintServer> paintServers) {
  final rawStroke = _getAttribute(el, 'stroke');
  if (rawStroke == '') {
    return null;
  }

  if (rawStroke.startsWith('url')) {
    return paintServers[rawStroke](size);
  }
  var rawOpacity = _getAttribute(el, 'stroke-opacity');
  if (rawOpacity == '') {
    rawOpacity = _getAttribute(el, 'opacity');
  }
  final double opacity =
      rawOpacity == '' ? 1.0 : double.parse(rawOpacity).clamp(0.0, 1.0);
  final Paint paint = new Paint()
    ..color = parseColor(rawStroke).withOpacity(opacity)
    ..style = PaintingStyle.stroke;

  final String rawStrokeCap = _getAttribute(el, 'stroke-linecap');
  paint.strokeCap = rawStrokeCap == 'null'
      ? StrokeCap.butt
      : StrokeCap.values.firstWhere(
          (sc) => sc.toString() == 'StrokeCap.$rawStrokeCap',
          orElse: () => StrokeCap.butt);

  final String rawLineJoin = _getAttribute(el, 'stroke-linejoin');
  paint.strokeJoin = rawLineJoin == ''
      ? StrokeJoin.miter
      : StrokeJoin.values.firstWhere(
          (sj) => sj.toString() == 'StrokeJoin.$rawLineJoin',
          orElse: () => StrokeJoin.miter);

  final String rawMiterLimit = _getAttribute(el, 'stroke-miterlimit');
  paint.strokeMiterLimit =
      rawMiterLimit == '' ? 4.0 : double.parse(rawMiterLimit);

  final String rawStrokeWidth = _getAttribute(el, 'stroke-width');
  paint.strokeWidth = rawStrokeWidth == '' ? 1.0 : double.parse(rawStrokeWidth);

  // TODO: Dash patterns not currently supported
  if (_getAttribute(el, 'stroke-dashoffset') != '' ||
      _getAttribute(el, 'stroke-dasharray') != '') {
    print('Warning: Dash patterns not currently supported');
  }

  return paint;
}

Paint parseFill(XmlElement el, Size size, Map<String, PaintServer> paintServers,
    {bool isShape = true}) {
  final rawFill = _getAttribute(el, 'fill');
  if (rawFill == '') {
    if (isShape) {
      return new Paint()
        ..color = colorBlack
        ..style = PaintingStyle.fill;
    } else {
      return null;
    }
  }

  if (rawFill.startsWith('url')) {
    return paintServers[rawFill](size);
  }

  var rawOpacity = _getAttribute(el, 'fill-opacity');
  if (rawOpacity == '') {
    rawOpacity = _getAttribute(el, 'opacity');
  }
  final opacity = rawOpacity == ''
      ? rawFill == 'none' ? 0.0 : 1.0
      : double.parse(rawOpacity).clamp(0.0, 1.0);

  final fill = parseColor(rawFill).withOpacity(opacity);

  return new Paint()
    ..color = fill
    ..style = PaintingStyle.fill;
}
