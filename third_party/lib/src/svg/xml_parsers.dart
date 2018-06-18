import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

import '../utilities/xml.dart';
import '../vector_drawable.dart';
import 'colors.dart';
import 'parsers.dart';

typedef Path SvgPathFactory(XmlElement el);

const Map<String, SvgPathFactory> svgPathParsers =
    const <String, SvgPathFactory>{
  'circle': parsePathFromCircle,
  'path': parsePathFromPath,
  'rect': parsePathFromRect,
  'polygon': parsePathFromPolygonOrLine,
  'polyline': parsePathFromPolygonOrLine,
  'ellipse': parsePathFromEllipse,
  'line': parsePathFromLine,
};

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

  final List<String> parts = viewBox.split(new RegExp(r'[ ,]+'));
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

String buildUrlIri(XmlElement def) => 'url(#${getAttribute(def, 'id')})';

/// Parses a <def> element, extracting <linearGradient> and (TODO) <radialGradient> elements into the `paintServers` map.
///
/// Returns any elements it was not able to process.
Iterable<XmlElement> parseDefs(
    XmlElement el, DrawableDefinitionServer definitions) sync* {
  for (XmlNode def in el.children) {
    if (def is XmlElement) {
      if (def.name.local.endsWith('Gradient')) {
        definitions.addPaintServer(buildUrlIri(def), parseGradient(def));
      } else if (def.name.local == 'clipPath') {
        definitions.addClipPath(buildUrlIri(def), parseClipPathDefinition(def));
      } else {
        yield def;
      }
    }
  }
}

double _parseDecimalOrPercentage(String val, {double multiplier = 1.0}) {
  if (val.endsWith('%')) {
    return double.parse(val.substring(0, val.length - 1)) / 100 * multiplier;
  } else {
    return double.parse(val);
  }
}

TileMode parseTileMode(XmlElement el) {
  final String spreadMethod = getAttribute(el, 'spreadMethod', def: 'pad');
  switch (spreadMethod) {
    case 'pad':
      return TileMode.clamp;
    case 'repeat':
      return TileMode.repeated;
    case 'reflect':
      return TileMode.mirror;
    default:
      return TileMode.clamp;
  }
}

void parseStops(
    List<XmlElement> stops, List<Color> colors, List<double> offsets) {
  for (int i = 0; i < stops.length; i++) {
    final String rawOpacity = getAttribute(stops[i], 'stop-opacity', def: '1');
    colors[i] = parseColor(getAttribute(stops[i], 'stop-color'))
        .withOpacity(double.parse(rawOpacity));

    final String rawOffset = getAttribute(stops[i], 'offset');
    offsets[i] = _parseDecimalOrPercentage(rawOffset);
  }
}

/// Parses an SVG <linearGradient> element into a [Paint].
PaintServer parseLinearGradient(XmlElement el) {
  final double x1 =
      _parseDecimalOrPercentage(getAttribute(el, 'x1', def: '0%'));
  final double x2 =
      _parseDecimalOrPercentage(getAttribute(el, 'x2', def: '100%'));
  final double y1 =
      _parseDecimalOrPercentage(getAttribute(el, 'y1', def: '0%'));
  final double y2 =
      _parseDecimalOrPercentage(getAttribute(el, 'y2', def: '0%'));

  final TileMode spreadMethod = parseTileMode(el);
  final List<XmlElement> stops = el.findElements('stop').toList();
  final List<Color> colors = new List<Color>(stops.length);
  final List<double> offsets = new List<double>(stops.length);

  parseStops(stops, colors, offsets);

  return (Rect bounds) {
    final Offset from = new Offset(
      bounds.left + (bounds.width * x1),
      bounds.left + (bounds.height * y1),
    );
    final Offset to = new Offset(
      bounds.left + (bounds.width * x2),
      bounds.left + (bounds.height * y2),
    );

    final Gradient gradient = new Gradient.linear(
      from,
      to,
      colors,
      offsets,
      spreadMethod,
    );

    return new Paint()..shader = gradient;
  };
}

/// Parses a <radialGradient> into a [Paint].
PaintServer parseRadialGradient(XmlElement el) {
  final String rawCx = getAttribute(el, 'cx', def: '50%');
  final String rawCy = getAttribute(el, 'cy', def: '50%');
  final TileMode spreadMethod = parseTileMode(el);

  final List<XmlElement> stops = el.findElements('stop').toList();

  final List<Color> colors = new List<Color>(stops.length);
  final List<double> offsets = new List<double>(stops.length);
  parseStops(stops, colors, offsets);

  return (Rect bounds) {
    final double cx = _parseDecimalOrPercentage(
      rawCx,
      multiplier: bounds.width + bounds.left + bounds.left,
    );
    final double cy = _parseDecimalOrPercentage(
      rawCy,
      multiplier: bounds.height + bounds.top + bounds.top,
    );
    final double r = _parseDecimalOrPercentage(
      getAttribute(el, 'r', def: '50%'),
      multiplier: (bounds.width + bounds.height) / 2,
    );
    final double fx = _parseDecimalOrPercentage(
      getAttribute(el, 'fx', def: rawCx),
      multiplier: bounds.width + (bounds.left * 2),
    );
    final double fy = _parseDecimalOrPercentage(
      getAttribute(el, 'fy', def: rawCy),
      multiplier: bounds.height + (bounds.top),
    );

    final Offset center = new Offset(cx, cy);
    final Offset focal =
        (fx != cx || fy != cy) ? new Offset(fx, fy) : new Offset(cx, cy);

    if (focal != center) {
      throw new UnsupportedError('Focal points not supported in this version');
    }

    final Gradient gradient = new Gradient.radial(
      center,
      r,
      colors,
      offsets,
      spreadMethod,
      null,
    );

    return new Paint()..shader = gradient;
  };
}

List<Path> parseClipPathDefinition(XmlElement el) {
  final List<Path> ret = <Path>[];
  Path currentPath;
  for (XmlNode child in el.children) {
    if (child is XmlElement) {
      final SvgPathFactory pathFn = svgPathParsers[child.name.local];
      if (pathFn != null) {
        final Path nextPath = applyTransformIfNeeded(pathFn(child), child);
        nextPath.fillType = parseFillRule(child, 'clip-rule');
        if (currentPath != null && nextPath.fillType != currentPath.fillType) {
          currentPath = nextPath;
          ret.add(currentPath);
        } else if (currentPath == null) {
          currentPath = nextPath;
          ret.add(currentPath);
        } else {
          currentPath.addPath(nextPath, Offset.zero);
        }
      } else {
        print('Unsupported clipPath child ${el.name.local}');
      }
    }
  }

  return ret;
}

List<Path> parseClipPath(XmlElement el, DrawableDefinitionServer definitions) {
  final String rawClipAttribute = getAttribute(el, 'clip-path');
  if (rawClipAttribute != '') {
    return definitions.getClipPath(rawClipAttribute);
  }

  return null;
}

/// Parses a <linearGradient> or <radialGradient> into a [Paint].
PaintServer parseGradient(XmlElement el) {
  if (el.name.local == 'linearGradient') {
    return parseLinearGradient(el);
  } else if (el.name.local == 'radialGradient') {
    return parseRadialGradient(el);
  }
  throw new StateError('Unknown gradient type ${el.name.local}');
}

/// Parses an @stroke-dasharray attribute into a [CircularIntervalList]
///
/// Does not currently support percentages.
CircularIntervalList<double> parseDashArray(XmlElement el) {
  final String rawDashArray = getAttribute(el, 'stroke-dasharray');
  if (rawDashArray == '') {
    return null;
  } else if (rawDashArray == 'none') {
    return DrawableStyle.emptyDashArray;
  }

  final List<String> parts = rawDashArray.split(new RegExp(r'[ ,]+'));
  return new CircularIntervalList<double>(
      parts.map((String part) => double.parse(part)).toList());
}

/// Parses a @stroke-dashoffset into a [DashOffset]
DashOffset parseDashOffset(XmlElement el) {
  final String rawDashOffset = getAttribute(el, 'stroke-dashoffset');
  if (rawDashOffset == '') {
    return null;
  }

  if (rawDashOffset.endsWith('%')) {
    final double percentage =
        double.parse(rawDashOffset.substring(0, rawDashOffset.length - 1)) /
            100;
    return new DashOffset.percentage(percentage);
  } else {
    return new DashOffset.absolute(double.parse(rawDashOffset));
  }
}

/// Parses an @opacity value into a [double], clamped between 0..1.
double parseOpacity(XmlElement el) {
  final String rawOpacity = getAttribute(el, 'opacity', def: null);
  if (rawOpacity != null) {
    return double.parse(rawOpacity).clamp(0.0, 1.0);
  }
  return null;
}

Paint _getDefinitionPaint(
    String iri, DrawableDefinitionServer definitions, Rect bounds) {
  final Paint paint = definitions.getPaint(iri, bounds);
  if (paint == null) {
    FlutterError.onError(
      new FlutterErrorDetails(
        exception: new StateError('Failed to find definition for $iri'),
        context: 'in _getDefinitionPaint',
        library: 'SVG',
        informationCollector: (StringBuffer buff) {
          buff.writeln(
              'This library only supports <defs> that are defined ahead of their references. '
              'This error can be caused when the desired definition is defined after the element '
              'referring to it (e.g. at the end of the file), or defined in another file.');
          buff.writeln(
              'This error is treated as non-fatal, but your SVG file will likely not render as intended');
        },
      ),
    );
  }
  return paint;
}

/// Parses a @stroke attribute into a [Paint].
Paint parseStroke(
    XmlElement el, Rect bounds, DrawableDefinitionServer definitions) {
  final String rawStroke = getAttribute(el, 'stroke');
  if (rawStroke == '') {
    return null;
  } else if (rawStroke == 'none') {
    return DrawableStyle.emptyPaint;
  }

  if (rawStroke.startsWith('url')) {
    return _getDefinitionPaint(rawStroke, definitions, bounds);
  }
  final String rawOpacity = getAttribute(el, 'stroke-opacity');

  final double opacity =
      rawOpacity == '' ? 1.0 : double.parse(rawOpacity).clamp(0.0, 1.0);
  final Paint paint = new Paint()
    ..color = parseColor(rawStroke).withOpacity(opacity)
    ..style = PaintingStyle.stroke;

  final String rawStrokeCap = getAttribute(el, 'stroke-linecap');
  paint.strokeCap = rawStrokeCap == 'null'
      ? StrokeCap.butt
      : StrokeCap.values.firstWhere(
          (StrokeCap sc) => sc.toString() == 'StrokeCap.$rawStrokeCap',
          orElse: () => StrokeCap.butt);

  final String rawLineJoin = getAttribute(el, 'stroke-linejoin');
  paint.strokeJoin = rawLineJoin == ''
      ? StrokeJoin.miter
      : StrokeJoin.values.firstWhere(
          (StrokeJoin sj) => sj.toString() == 'StrokeJoin.$rawLineJoin',
          orElse: () => StrokeJoin.miter);

  final String rawMiterLimit = getAttribute(el, 'stroke-miterlimit');
  paint.strokeMiterLimit =
      rawMiterLimit == '' ? 4.0 : double.parse(rawMiterLimit);

  final String rawStrokeWidth = getAttribute(el, 'stroke-width');
  paint.strokeWidth = rawStrokeWidth == '' ? 1.0 : double.parse(rawStrokeWidth);

  return paint;
}

Paint parseFill(XmlElement el, Rect bounds,
    DrawableDefinitionServer definitions, Color defaultFillIfNotSpecified) {
  final String rawFill = getAttribute(el, 'fill');
  if (rawFill == '') {
    if (defaultFillIfNotSpecified == null) {
      return null;
    }
    return new Paint()..color = defaultFillIfNotSpecified;
  } else if (rawFill == 'none') {
    return DrawableStyle.emptyPaint;
  }

  if (rawFill.startsWith('url')) {
    return _getDefinitionPaint(rawFill, definitions, bounds);
  }

  final String rawOpacity = getAttribute(el, 'fill-opacity');
  final double opacity = rawOpacity == ''
      ? rawFill == 'none' ? 0.0 : 1.0
      : double.parse(rawOpacity).clamp(0.0, 1.0);

  final Color fill = parseColor(rawFill).withOpacity(opacity);

  return new Paint()
    ..color = fill
    ..style = PaintingStyle.fill;
}

PathFillType parseFillRule(XmlElement el,
    [String attr = 'fill-rule', String def = 'nonzero']) {
  final String rawFillRule = getAttribute(el, attr, def: def);
  return parseRawFillRule(rawFillRule);
}

Path parsePathFromRect(XmlElement el) {
  final double x = double.parse(getAttribute(el, 'x', def: '0'));
  final double y = double.parse(getAttribute(el, 'y', def: '0'));
  final double w = double.parse(getAttribute(el, 'width', def: '0'));
  final double h = double.parse(getAttribute(el, 'height', def: '0'));
  final Rect rect = new Rect.fromLTWH(x, y, w, h);
  String rxRaw = getAttribute(el, 'rx', def: '0');
  String ryRaw = getAttribute(el, 'ry', def: '0');
  rxRaw ??= ryRaw;
  ryRaw ??= rxRaw;

  if (rxRaw != null && rxRaw != '') {
    final double rx = double.parse(rxRaw);
    final double ry = double.parse(ryRaw);

    return new Path()..addRRect(new RRect.fromRectXY(rect, rx, ry));
  }

  return new Path()..addRect(rect);
}

Path parsePathFromLine(XmlElement el) {
  final double x1 = double.parse(getAttribute(el, 'x1', def: '0'));
  final double x2 = double.parse(getAttribute(el, 'x2', def: '0'));
  final double y1 = double.parse(getAttribute(el, 'y1', def: '0'));
  final double y2 = double.parse(getAttribute(el, 'y2', def: '0'));

  return new Path()
    ..moveTo(x1, y1)
    ..lineTo(x2, y2);
}

Path parsePathFromPolygonOrLine(XmlElement el) {
  final String points = getAttribute(el, 'points');
  if (points == '') {
    return null;
  }
  return parseSvgPathData('M' + points + 'z');
}

Path parsePathFromPath(XmlElement el) {
  final String d = getAttribute(el, 'd');
  return parseSvgPathData(d);
}

Path parsePathFromCircle(XmlElement el) {
  final double cx = double.parse(getAttribute(el, 'cx', def: '0'));
  final double cy = double.parse(getAttribute(el, 'cy', def: '0'));
  final double r = double.parse(getAttribute(el, 'r', def: '0'));
  final Rect oval = new Rect.fromCircle(center: new Offset(cx, cy), radius: r);
  return new Path()..addOval(oval);
}

Path parsePathFromEllipse(XmlElement el) {
  final double cx = double.parse(getAttribute(el, 'cx', def: '0'));
  final double cy = double.parse(getAttribute(el, 'cy', def: '0'));
  final double rx = double.parse(getAttribute(el, 'rx', def: '0'));
  final double ry = double.parse(getAttribute(el, 'ry', def: '0'));

  final Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);
  return new Path()..addOval(r);
}

Path applyTransformIfNeeded(Path path, XmlElement el) {
  assert(path != null);
  assert(el != null);

  final Matrix4 transform =
      parseTransform(getAttribute(el, 'transform', def: null));

  if (transform != null) {
    return path.transform(transform.storage);
  } else {
    return path;
  }
}
