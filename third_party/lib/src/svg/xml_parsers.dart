import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

import '../svg_parser.dart';
import '../utilities/xml.dart';
import '../vector_drawable.dart';
import 'colors.dart';
import 'parsers.dart';

typedef SvgPathFactory = Path Function(XmlElement el);

const Map<String, SvgPathFactory> svgPathParsers = <String, SvgPathFactory>{
  'circle': parsePathFromCircle,
  'path': parsePathFromPath,
  'rect': parsePathFromRect,
  'polygon': parsePathFromPolygon,
  'polyline': parsePathFromPolyline,
  'ellipse': parsePathFromEllipse,
  'line': parsePathFromLine,
};

double _parseRawWidthHeight(String raw) {
  if (raw == '100%' || raw == '') {
    return double.infinity;
  }
  assert(() {
    final RegExp notDigits = RegExp(r'[^\d\.]');
    if (!raw.endsWith('px') && raw.contains(notDigits)) {
      print(
          'Warning: Flutter SVG only supports the following formats for `width` and `height` on the SVG root:\n'
          '  width="100%"\n'
          '  width="100px"\n'
          '  width="100" (where the number will be treated as pixels).\n'
          'The supplied value ($raw) will be discarded and treated as if it had not been specified.');
    }
    return true;
  }());
  return double.tryParse(raw.replaceAll('px', '')) ?? double.infinity;
}

/// Parses an SVG @viewBox attribute (e.g. 0 0 100 100) to a [Rect].
///
/// The [nullOk] parameter controls whether this function should throw if there is no
/// viewBox or width/height parameters.
///
/// The [respectWidthHeight] parameter specifies whether `width` and `height` attributes
/// on the root SVG element should be treated in accordance with the specification.
DrawableViewport parseViewBox(
  XmlElement svg, {
  bool nullOk = false,
}) {
  final String viewBox = getAttribute(svg, 'viewBox');
  final String rawWidth = getAttribute(svg, 'width');
  final String rawHeight = getAttribute(svg, 'height');

  if (viewBox == '' && rawWidth == '' && rawHeight == '') {
    if (nullOk) {
      return null;
    }
    throw StateError('SVG did not specify dimensions\n\n'
        'The SVG library looks for a `viewBox` or `width` and `height` attribute '
        'to determine the viewport boundary of the SVG.  Note that these attributes, '
        'as with all SVG attributes, are case sensitive.\n'
        'During processing, the following attributes were found:\n'
        '  ${svg.attributes}');
  }

  final double width = _parseRawWidthHeight(rawWidth);
  final double height = _parseRawWidthHeight(rawHeight);

  if (viewBox == '') {
    return DrawableViewport(
      Size(width, height),
      Size(width, height),
    );
  }

  final List<String> parts = viewBox.split(RegExp(r'[ ,]+'));
  if (parts.length < 4) {
    throw StateError('viewBox element must be 4 elements long');
  }

  return DrawableViewport(
    Size(width, height),
    Size(
      double.parse(parts[2]),
      double.parse(parts[3]),
    ),
    viewBoxOffset: Offset(
      -double.parse(parts[0]),
      -double.parse(parts[1]),
    ),
  );
}

String buildUrlIri(XmlElement def) => 'url(#${getAttribute(def, 'id')})';

const String emptyUrlIri = 'url(#)';

/// Parses a <def> element, extracting <linearGradient> and <radialGradient> elements into the `paintServers` map.
///
/// Returns any elements it was not able to process.
Iterable<XmlElement> parseDefs(XmlElement el,
    DrawableDefinitionServer definitions, Rect rootBounds) sync* {
  for (XmlNode def in el.children) {
    if (def is XmlElement) {
      if (def.name.local.endsWith('Gradient')) {
        definitions.addPaintServer(
          buildUrlIri(def),
          parseGradient(def, rootBounds),
        );
      } else if (def.name.local == 'clipPath') {
        definitions.addClipPath(
          buildUrlIri(def),
          parseClipPathDefinition(
            def,
            definitions,
          ),
        );
      } else {
        yield def;
      }
    }
  }
}

double _parseDecimalOrPercentage(String val, {double multiplier = 1.0}) {
  if (_isPercentage(val)) {
    return _parsePercentage(val, multiplier: multiplier);
  } else {
    return double.parse(val);
  }
}

double _parsePercentage(String val, {double multiplier = 1.0}) {
  return double.parse(val.substring(0, val.length - 1)) / 100 * multiplier;
}

bool _isPercentage(String val) => val.endsWith('%');

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

    final String rawOffset = getAttribute(stops[i], 'offset', def: '0%');
    offsets[i] = _parseDecimalOrPercentage(rawOffset);
  }
}

/// Parses an SVG <linearGradient> element into a [Paint].
PaintServer parseLinearGradient(XmlElement el, Rect rootBounds) {
  final String gradientUnits =
      getAttribute(el, 'gradientUnits', def: 'objectBoundingBox');
  final bool isObjectBoundingBox = gradientUnits == 'objectBoundingBox';

  final String x1 = getAttribute(el, 'x1', def: '0%');
  final String x2 = getAttribute(el, 'x2', def: '100%');
  final String y1 = getAttribute(el, 'y1', def: '0%');
  final String y2 = getAttribute(el, 'y2', def: '0%');

  final TileMode spreadMethod = parseTileMode(el);
  final List<XmlElement> stops = el.findElements('stop').toList();
  final List<Color> colors = List<Color>(stops.length);
  final List<double> offsets = List<double>(stops.length);

  parseStops(stops, colors, offsets);

  final Matrix4 originalTransform =
      parseTransform(getAttribute(el, 'gradientTransform', def: null));

  return (Rect bounds) {
    Vector3 from, to;
    Matrix4 transform = originalTransform?.clone() ?? Matrix4.identity();

    if (isObjectBoundingBox) {
      final Matrix4 scale =
          affineMatrix(bounds.width, 0.0, 0.0, bounds.height, 0.0, 0.0);
      final Matrix4 translate =
          affineMatrix(1.0, 0.0, 0.0, 1.0, bounds.left, bounds.top);
      transform = translate.multiplied(scale)..multiply(transform);

      final Offset fromOffset = Offset(
        _parseDecimalOrPercentage(x1),
        _parseDecimalOrPercentage(y1),
      );
      final Offset toOffset = Offset(
        _parseDecimalOrPercentage(x2),
        _parseDecimalOrPercentage(y2),
      );

      from = Vector3(
        fromOffset.dx,
        fromOffset.dy,
        0.0,
      );
      to = Vector3(
        toOffset.dx,
        toOffset.dy,
        0.0,
      );
    } else {
      final Offset fromOffset = Offset(
        _isPercentage(x1)
            ? _parsePercentage(x1) * rootBounds.width + rootBounds.left
            : double.parse(x1),
        _isPercentage(y1)
            ? _parsePercentage(y1) * rootBounds.height + rootBounds.top
            : double.parse(y1),
      );

      final Offset toOffset = Offset(
        _isPercentage(x2)
            ? _parsePercentage(x2) * rootBounds.width + rootBounds.left
            : double.parse(x2),
        _isPercentage(y2)
            ? _parsePercentage(y2) * rootBounds.height + rootBounds.top
            : double.parse(y2),
      );

      from = Vector3(fromOffset.dx, fromOffset.dy, 0.0);
      to = Vector3(toOffset.dx, toOffset.dy, 0.0);
    }

    if (transform != null) {
      from = transform.transform3(from);
      to = transform.transform3(to);
    }

    return Gradient.linear(
      Offset(from.x, from.y),
      Offset(to.x, to.y),
      colors,
      offsets,
      spreadMethod,
    );
  };
}

/// Parses a <radialGradient> into a [Paint].
PaintServer parseRadialGradient(XmlElement el, Rect rootBounds) {
  final String gradientUnits =
      getAttribute(el, 'gradientUnits', def: 'objectBoundingBox');
  final bool isObjectBoundingBox = gradientUnits == 'objectBoundingBox';

  final String rawCx = getAttribute(el, 'cx', def: '50%');
  final String rawCy = getAttribute(el, 'cy', def: '50%');
  final String rawR = getAttribute(el, 'r', def: '50%');
  final String rawFx = getAttribute(el, 'fx', def: rawCx);
  final String rawFy = getAttribute(el, 'fy', def: rawCy);
  final TileMode spreadMethod = parseTileMode(el);

  final List<XmlElement> stops = el.findElements('stop').toList();

  final List<Color> colors = List<Color>(stops.length);
  final List<double> offsets = List<double>(stops.length);
  parseStops(stops, colors, offsets);

  final Matrix4 originalTransform =
      parseTransform(getAttribute(el, 'gradientTransform', def: null));

  return (Rect bounds) {
    double cx, cy, r, fx, fy;
    Matrix4 transform = originalTransform?.clone() ?? Matrix4.identity();

    if (isObjectBoundingBox) {
      final Matrix4 scale =
          affineMatrix(bounds.width, 0.0, 0.0, bounds.height, 0.0, 0.0);
      final Matrix4 translate =
          affineMatrix(1.0, 0.0, 0.0, 1.0, bounds.left, bounds.top);
      transform = translate.multiplied(scale)..multiply(transform);

      cx = _parseDecimalOrPercentage(rawCx);
      cy = _parseDecimalOrPercentage(rawCy);
      r = _parseDecimalOrPercentage(rawR);
      fx = _parseDecimalOrPercentage(rawFx);
      fy = _parseDecimalOrPercentage(rawFy);
    } else {
      cx = _isPercentage(rawCx)
          ? _parsePercentage(rawCx) * rootBounds.width + rootBounds.left
          : double.parse(rawCx);
      cy = _isPercentage(rawCy)
          ? _parsePercentage(rawCy) * rootBounds.height + rootBounds.top
          : double.parse(rawCy);
      r = _isPercentage(rawR)
          ? _parsePercentage(rawR) *
              ((rootBounds.height + rootBounds.width) / 2)
          : double.parse(rawR);
      fx = _isPercentage(rawFx)
          ? _parsePercentage(rawFx) * rootBounds.width + rootBounds.left
          : double.parse(rawFx);
      fy = _isPercentage(rawFy)
          ? _parsePercentage(rawFy) * rootBounds.height + rootBounds.top
          : double.parse(rawFy);
    }

    final Offset center = Offset(cx, cy);
    final Offset focal =
        (fx != cx || fy != cy) ? Offset(fx, fy) : Offset(cx, cy);

    return Gradient.radial(
      center,
      r,
      colors,
      offsets,
      spreadMethod,
      transform?.storage,
      focal,
      0.0,
    );
  };
}

List<Path> parseClipPathDefinition(
  XmlElement el,
  DrawableDefinitionServer definitions,
) {
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
      } else if (child.name.local == 'use') {
        final String xlinkHref = getHrefAttribute(child);
        final DrawableStyleable target = definitions.getDrawable('url($xlinkHref)');
        print(target);
        if (target is DrawableShape) {
          return <Path>[target.path];
        } else if (target is DrawableGroup) {
          return target.children
              .whereType<DrawableShape>()
              .map<Path>((DrawableShape d) => d.path)
              .toList();
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
PaintServer parseGradient(XmlElement el, Rect rootBounds) {
  if (el.name.local == 'linearGradient') {
    return parseLinearGradient(el, rootBounds);
  } else if (el.name.local == 'radialGradient') {
    return parseRadialGradient(el, rootBounds);
  }
  throw StateError('Unknown gradient type ${el.name.local}');
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

  final List<String> parts = rawDashArray.split(RegExp(r'[ ,]+'));
  return CircularIntervalList<double>(
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
    return DashOffset.percentage(percentage);
  } else {
    return DashOffset.absolute(double.parse(rawDashOffset));
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

DrawablePaint _getDefinitionPaint(PaintingStyle paintingStyle, String iri,
    DrawableDefinitionServer definitions, Rect bounds,
    {double opacity}) {
  final Shader shader = definitions.getPaint(iri, bounds);
  if (shader == null) {
    FlutterError.onError(
      FlutterErrorDetails(
        exception: StateError('Failed to find definition for $iri'),
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

  return DrawablePaint(
    paintingStyle,
    shader: shader,
    color: opacity != null ? Color.fromRGBO(255, 255, 255, opacity) : null,
  );
}

/// Parses a @stroke attribute into a [Paint].
DrawablePaint parseStroke(
  XmlElement el,
  Rect bounds,
  DrawableDefinitionServer definitions,
  DrawablePaint parentStroke,
) {
  final String rawStroke = getAttribute(el, 'stroke');
  final String rawOpacity = getAttribute(el, 'stroke-opacity');

  final double opacity = rawOpacity == ''
      ? parentStroke?.color?.opacity ?? 1.0
      : double.parse(rawOpacity).clamp(0.0, 1.0);

  if (rawStroke.startsWith('url')) {
    return _getDefinitionPaint(
      PaintingStyle.stroke,
      rawStroke,
      definitions,
      bounds,
      opacity: opacity,
    );
  }
  if (rawStroke == '' && DrawablePaint.isEmpty(parentStroke)) {
    return null;
  }
  if (rawStroke == 'none') {
    return DrawablePaint.empty;
  }

  final String rawStrokeCap = getAttribute(el, 'stroke-linecap');
  final String rawLineJoin = getAttribute(el, 'stroke-linejoin');
  final String rawMiterLimit = getAttribute(el, 'stroke-miterlimit');
  final String rawStrokeWidth = getAttribute(el, 'stroke-width');

  final DrawablePaint paint = DrawablePaint(
    PaintingStyle.stroke,
    color: rawStroke == ''
        ? (parentStroke?.color ?? colorBlack).withOpacity(opacity)
        : parseColor(rawStroke).withOpacity(opacity),
    strokeCap: rawStrokeCap == 'null'
        ? parentStroke?.strokeCap ?? StrokeCap.butt
        : StrokeCap.values.firstWhere(
            (StrokeCap sc) => sc.toString() == 'StrokeCap.$rawStrokeCap',
            orElse: () => StrokeCap.butt,
          ),
    strokeJoin: rawLineJoin == ''
        ? parentStroke?.strokeJoin ?? StrokeJoin.miter
        : StrokeJoin.values.firstWhere(
            (StrokeJoin sj) => sj.toString() == 'StrokeJoin.$rawLineJoin',
            orElse: () => StrokeJoin.miter,
          ),
    strokeMiterLimit: rawMiterLimit == ''
        ? parentStroke?.strokeMiterLimit ?? 4.0
        : double.parse(rawMiterLimit),
    strokeWidth: rawStrokeWidth == ''
        ? parentStroke?.strokeWidth ?? 1.0
        : double.parse(rawStrokeWidth),
  );
  return paint;
}

DrawablePaint parseFill(
  XmlElement el,
  Rect bounds,
  DrawableDefinitionServer definitions,
  DrawablePaint parentFill,
) {
  final String rawFill = getAttribute(el, 'fill');
  final String rawOpacity = getAttribute(el, 'fill-opacity');

  final double opacity = rawOpacity == ''
      ? parentFill?.color?.opacity ?? 1.0
      : double.parse(rawOpacity).clamp(0.0, 1.0);

  if (rawFill.startsWith('url')) {
    return _getDefinitionPaint(
      PaintingStyle.fill,
      rawFill,
      definitions,
      bounds,
      opacity: opacity,
    );
  }
  if (rawFill == '' && parentFill == DrawablePaint.empty) {
    return null;
  }
  if (rawFill == 'none') {
    return DrawablePaint.empty;
  }

  return DrawablePaint(
    PaintingStyle.fill,
    color: rawFill == ''
        ? (parentFill?.color ?? colorBlack).withOpacity(opacity)
        : parseColor(rawFill).withOpacity(opacity),
  );
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
  final Rect rect = Rect.fromLTWH(x, y, w, h);
  String rxRaw = getAttribute(el, 'rx', def: null);
  String ryRaw = getAttribute(el, 'ry', def: null);
  rxRaw ??= ryRaw;
  ryRaw ??= rxRaw;

  if (rxRaw != null && rxRaw != '') {
    final double rx = double.parse(rxRaw);
    final double ry = double.parse(ryRaw);

    return Path()..addRRect(RRect.fromRectXY(rect, rx, ry));
  }

  return Path()..addRect(rect);
}

Path parsePathFromLine(XmlElement el) {
  final double x1 = double.parse(getAttribute(el, 'x1', def: '0'));
  final double x2 = double.parse(getAttribute(el, 'x2', def: '0'));
  final double y1 = double.parse(getAttribute(el, 'y1', def: '0'));
  final double y2 = double.parse(getAttribute(el, 'y2', def: '0'));

  return Path()
    ..moveTo(x1, y1)
    ..lineTo(x2, y2);
}

Path parsePathFromPolygon(XmlElement el) {
  return parsePathFromPoints(el, true);
}

Path parsePathFromPolyline(XmlElement el) {
  return parsePathFromPoints(el, false);
}

Path parsePathFromPoints(XmlElement el, bool close) {
  final String points = getAttribute(el, 'points');
  if (points == '') {
    return null;
  }
  final String path = 'M$points${close ? 'z' : ''}';

  return parseSvgPathData(path);
}

Path parsePathFromPath(XmlElement el) {
  final String d = getAttribute(el, 'd');
  return parseSvgPathData(d);
}

Path parsePathFromCircle(XmlElement el) {
  final double cx = double.parse(getAttribute(el, 'cx', def: '0'));
  final double cy = double.parse(getAttribute(el, 'cy', def: '0'));
  final double r = double.parse(getAttribute(el, 'r', def: '0'));
  final Rect oval = Rect.fromCircle(center: Offset(cx, cy), radius: r);
  return Path()..addOval(oval);
}

Path parsePathFromEllipse(XmlElement el) {
  final double cx = double.parse(getAttribute(el, 'cx', def: '0'));
  final double cy = double.parse(getAttribute(el, 'cy', def: '0'));
  final double rx = double.parse(getAttribute(el, 'rx', def: '0'));
  final double ry = double.parse(getAttribute(el, 'ry', def: '0'));

  final Rect r = Rect.fromLTWH(cx - rx, cy - ry, rx * 2, ry * 2);
  return Path()..addOval(r);
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
