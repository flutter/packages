import 'dart:ui';

import 'package:xml/xml.dart';

import '../vector_painter.dart';
import '../utilities/xml.dart';
import 'colors.dart';

/// Parses an SVG @viewBox attribute (e.g. 0 0 100 100) to a [Rect].
Rect parseViewBox(XmlElement svg) {
  final String viewBox = getAttribute(svg, 'viewBox');

  if (viewBox == '') {
    final RegExp notDigits = new RegExp(r'[^\d\.]');
    final String rawWidth =
        getAttribute(svg, 'width').replaceAll(notDigits, '');
    final String rawHeight =
        getAttribute(svg, 'height').replaceAll(notDigits, '');
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
void parseDefs(XmlElement el, Map<String, PaintServer> paintServers) {
  el.children.forEach((XmlNode def) {
    if (def is XmlElement) {
      if (def.name.local.endsWith('Gradient')) {
        paintServers['url(#${getAttribute(def, 'id')})'] =
            (Rect bounds) => parseGradient(def, bounds);
      }
    }
  });
}

double _parseDecimalOrPercentage(String val) {
  if (val.endsWith('%')) {
    return double.parse(val.substring(0, val.length - 1)) / 100;
  } else {
    return double.parse(val);
  }
}

/// Parses an SVG <linearGradient> element into a [Paint].
Paint parseLinearGradient(XmlElement el, Rect bounds) {
  final double x1 = _parseDecimalOrPercentage(getAttribute(el, 'x1', '0%'));
  final double x2 = _parseDecimalOrPercentage(getAttribute(el, 'x2', '100%'));
  final double y1 = _parseDecimalOrPercentage(getAttribute(el, 'y1', '0%'));
  final double y2 = _parseDecimalOrPercentage(getAttribute(el, 'y2', '0%'));

  final Offset from = new Offset(
    bounds.left + (bounds.width * x1),
    bounds.left + (bounds.height * y1),
  );
  final Offset to = new Offset(
    bounds.left + (bounds.width * x2),
    bounds.left + (bounds.height * y2),
  );

  final stops = el.findElements('stop').toList();
  final Gradient gradient = new Gradient.linear(
    from,
    to,
    stops.map((stop) {
      final String rawOpacity = getAttribute(stop, 'stop-opacity', '1');
      return parseColor(getAttribute(stop, 'stop-color'))
          .withOpacity(double.parse(rawOpacity));
    }).toList(),
    stops.map((stop) {
      final String rawOffset = getAttribute(stop, 'offset');
      return _parseDecimalOrPercentage(rawOffset);
    }).toList(),
  );

  return new Paint()..shader = gradient;
}

/// Parses a <radialGradient> into a [Paint].
Paint parseRadialGradient(XmlElement el, Rect bounds) {
  final String rawCx = getAttribute(el, 'cx', '50%');
  final String rawCy = getAttribute(el, 'cy', '50%');
  final double cx = _parseDecimalOrPercentage(rawCx);
  final double cy = _parseDecimalOrPercentage(rawCy);
  final double r = _parseDecimalOrPercentage(getAttribute(el, 'r', '50%'));
  final double fx = _parseDecimalOrPercentage(getAttribute(el, 'fx', rawCx));
  final double fy = _parseDecimalOrPercentage(getAttribute(el, 'fy', rawCy));

  if (fx != cx || fy != cy) {
    throw new UnsupportedError(
        'Focal points not supported by this implementation');
  }

  final stops = el.findElements('stop').toList();
  final Gradient gradient = new Gradient.radial(
    new Offset(cx, cy),
    r,
    stops.map((stop) {
      final String rawOpacity = getAttribute(stop, 'stop-opacity', '1');
      return parseColor(getAttribute(stop, 'stop-color'))
          .withOpacity(double.parse(rawOpacity));
    }).toList(),
    stops.map((stop) {
      final String rawOffset = getAttribute(stop, 'offset');
      return _parseDecimalOrPercentage(rawOffset);
    }).toList(),
  );

  return new Paint()..shader = gradient;
}

/// Parses a <linearGradient> or <radialGradient> into a [Paint].
Paint parseGradient(XmlElement el, Rect bounds) {
  if (el.name.local == 'linearGradient') {
    return parseLinearGradient(el, bounds);
  } else if (el.name.local == 'radialGradient') {
    return parseRadialGradient(el, bounds);
  }
  throw new StateError('Unknown gradient type ${el.name.local}');
}

/// Parses a @stroke attribute into a [Paint].
Paint parseStroke(
    XmlElement el, Rect bounds, Map<String, PaintServer> paintServers) {
  final rawStroke = getAttribute(el, 'stroke');
  if (rawStroke == '') {
    return null;
  }

  if (rawStroke.startsWith('url')) {
    return paintServers[rawStroke](bounds);
  }
  var rawOpacity = getAttribute(el, 'stroke-opacity');
  if (rawOpacity == '') {
    rawOpacity = getAttribute(el, 'opacity');
  }
  final double opacity =
      rawOpacity == '' ? 1.0 : double.parse(rawOpacity).clamp(0.0, 1.0);
  final Paint paint = new Paint()
    ..color = parseColor(rawStroke).withOpacity(opacity)
    ..style = PaintingStyle.stroke;

  final String rawStrokeCap = getAttribute(el, 'stroke-linecap');
  paint.strokeCap = rawStrokeCap == 'null'
      ? StrokeCap.butt
      : StrokeCap.values.firstWhere(
          (sc) => sc.toString() == 'StrokeCap.$rawStrokeCap',
          orElse: () => StrokeCap.butt);

  final String rawLineJoin = getAttribute(el, 'stroke-linejoin');
  paint.strokeJoin = rawLineJoin == ''
      ? StrokeJoin.miter
      : StrokeJoin.values.firstWhere(
          (sj) => sj.toString() == 'StrokeJoin.$rawLineJoin',
          orElse: () => StrokeJoin.miter);

  final String rawMiterLimit = getAttribute(el, 'stroke-miterlimit');
  paint.strokeMiterLimit =
      rawMiterLimit == '' ? 4.0 : double.parse(rawMiterLimit);

  final String rawStrokeWidth = getAttribute(el, 'stroke-width');
  paint.strokeWidth = rawStrokeWidth == '' ? 1.0 : double.parse(rawStrokeWidth);

  // TODO: Dash patterns not currently supported
  if (getAttribute(el, 'stroke-dashoffset') != '' ||
      getAttribute(el, 'stroke-dasharray') != '') {
    print('Warning: Dash patterns not currently supported');
  }

  return paint;
}

Paint parseFill(
    XmlElement el, Rect bounds, Map<String, PaintServer> paintServers) {
  final rawFill = getAttribute(el, 'fill');
  if (rawFill == '') {
    return null;
  }

  if (rawFill.startsWith('url')) {
    return paintServers[rawFill](bounds);
  }

  var rawOpacity = getAttribute(el, 'fill-opacity');
  if (rawOpacity == '') {
    rawOpacity = getAttribute(el, 'opacity');
  }
  final opacity = rawOpacity == ''
      ? rawFill == 'none' ? 0.0 : 1.0
      : double.parse(rawOpacity).clamp(0.0, 1.0);

  final fill = parseColor(rawFill).withOpacity(opacity);

  return new Paint()
    ..color = fill
    ..style = PaintingStyle.fill;
}

PathFillType parseFillRule(XmlElement el) {
  final String rawFillRule = getAttribute(el, 'fill-rule', 'nonzero');
  return rawFillRule == 'nonzero' ? PathFillType.nonZero : PathFillType.evenOdd;
}
