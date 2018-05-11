import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';

import 'vector_painter.dart';
import 'svg/colors.dart';
import 'svg/parsers.dart';
import 'svg/xml_parsers.dart';
import 'utilities/xml.dart';

typedef DrawableSvgShape SvgShapeFactory(XmlElement el,
    Map<String, PaintServer> paintServers, DrawableStyle parentStyle);

final Map<String, SvgShapeFactory> _shapes = {
  'circle': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgCircle(el, paintServers, parentStyle),
  'path': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgPath(el, paintServers, parentStyle),
  'rect': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgRect(el, paintServers, parentStyle),
  'polygon': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgPolygonOrLine(el, paintServers, parentStyle),
  'polyline': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgPolygonOrLine(el, paintServers, parentStyle),
  'ellipse': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgEllipse(el, paintServers, parentStyle),
  'line': (XmlElement el, Map<String, PaintServer> paintServers,
          DrawableStyle parentStyle) =>
      new DrawableSvgShape.fromSvgLine(el, paintServers, parentStyle),
};

/// An SVG Shape element that will be drawn to the canvas.
class DrawableSvgShape extends DrawableShape {
  const DrawableSvgShape(Path path, DrawableStyle style) : super(path, style);

  /// Applies the transformation in the @transform attribute to the path.
  static Path transformPath(Path path, XmlElement el) {
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

  static _createDrawable(Path path, Map<String, PaintServer> paintServers,
      XmlElement el, DrawableStyle parentStyle) {
    assert(path != null);

    final Color defaultFill = parentStyle?.fill != null ? null : colorBlack;

    return new DrawableSvgShape(
      transformPath(path, el),
      parseStyle(el, paintServers, path.getBounds(),
          defaultFillIfNotSpecified: defaultFill),
    );
  }

  /// Creates a [DrawableSvgShape] from an SVG <circle> element.
  factory DrawableSvgShape.fromSvgCircle(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final cx = double.parse(getAttribute(el, 'cx', def: '0'));
    final cy = double.parse(getAttribute(el, 'cy', def: '0'));
    final r = double.parse(getAttribute(el, 'r', def: '0'));
    final oval = new Rect.fromCircle(center: new Offset(cx, cy), radius: r);
    final path = new Path()..addOval(oval);

    return _createDrawable(path, paintServers, el, parentStyle);
  }

  /// Creates a [DrawableSvgShape] from an SVG <path> element.
  factory DrawableSvgShape.fromSvgPath(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final d = getAttribute(el, 'd');
    final Path path = parseSvgPathData(d);

    return _createDrawable(path, paintServers, el, parentStyle);
  }

  /// Creates a [DrawableSvgShape] from an SVG <rect> element.
  factory DrawableSvgShape.fromSvgRect(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final double x = double.parse(getAttribute(el, 'x', def: '0'));
    final double y = double.parse(getAttribute(el, 'y', def: '0'));
    final double w = double.parse(getAttribute(el, 'width', def: '0'));
    final double h = double.parse(getAttribute(el, 'height', def: '0'));
    final Rect rect = new Rect.fromLTWH(x, y, w, h);
    String rxRaw = getAttribute(el, 'rx', def: '0');
    String ryRaw = getAttribute(el, 'ry', def: '0');
    rxRaw ??= ryRaw;
    ryRaw ??= rxRaw;

    if ((rxRaw != null && rxRaw != '')) {
      final double rx = double.parse(rxRaw);
      final double ry = double.parse(ryRaw);

      return _createDrawable(
        new Path()..addRRect(new RRect.fromRectXY(rect, rx, ry)),
        paintServers,
        el,
        parentStyle,
      );
    }

    final path = new Path()..addRect(rect);
    return _createDrawable(path, paintServers, el, parentStyle);
  }

  /// Creates a [DrawableSvgShape] from an SVG <polyline> or <polyline> element.
  factory DrawableSvgShape.fromSvgPolygonOrLine(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final points = getAttribute(el, 'points');
    if (points == '') {
      return _createDrawable(null, paintServers, el, parentStyle);
    }
    final path = parseSvgPathData('M' + points + 'z');

    return _createDrawable(path, paintServers, el, parentStyle);
  }

  /// Creates a [DrawableSvgShape] from an SVG <ellipse> element.
  factory DrawableSvgShape.fromSvgEllipse(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final cx = double.parse(getAttribute(el, 'cx', def: '0'));
    final cy = double.parse(getAttribute(el, 'cy', def: '0'));
    final rx = double.parse(getAttribute(el, 'rx', def: '0'));
    final ry = double.parse(getAttribute(el, 'ry', def: '0'));

    Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);

    return _createDrawable(
        new Path()..addOval(r), paintServers, el, parentStyle);
  }

  /// Creates a [DrawableSvgShape] from an SVG <line> element.
  factory DrawableSvgShape.fromSvgLine(XmlElement el,
      Map<String, PaintServer> paintServers, DrawableStyle parentStyle) {
    final x1 = double.parse(getAttribute(el, 'x1', def: '0'));
    final x2 = double.parse(getAttribute(el, 'x2', def: '0'));
    final y1 = double.parse(getAttribute(el, 'y1', def: '0'));
    final y2 = double.parse(getAttribute(el, 'y2', def: '0'));

    final path = new Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);
    return _createDrawable(path, paintServers, el, parentStyle);
  }
}

/// Creates a [Drawable] from an SVG <g> or shape element.  Also handles parsing <defs> and gradients.
///
/// If an unsupported element is encountered, it will be created as a [DrawableNoop].
Drawable parseSvgElement(XmlElement el, Map<String, PaintServer> paintServers,
    Rect bounds, DrawableStyle parentStyle) {
  final SvgShapeFactory shapeFn = _shapes[el.name.local];
  if (shapeFn != null) {
    return shapeFn(el, paintServers, parentStyle);
  } else if (el.name.local == 'defs') {
    parseDefs(el, paintServers);
    return new DrawableNoop(el.name.local);
  } else if (el.name.local.endsWith('Gradient')) {
    paintServers['url(#${getAttribute(el, 'id')})'] =
        (Rect bounds) => parseGradient(el, bounds);
    return new DrawableNoop(el.name.local);
  } else if (el.name.local == 'g' || el.name.local == 'a') {
    return parseSvgGroup(el, paintServers, bounds);
  } else if (el.name.local == 'text') {
    return parseSvgText(el, paintServers, bounds);
  } else if (el.name.local == 'svg') {
    throw new UnsupportedError(
        'Nested SVGs not supported in this implementation.');
  }
  print('Unhandled element ${el.name.local}');
  return new DrawableNoop(el.name.local);
}

Drawable parseSvgText(
    XmlElement el, Map<String, PaintServer> paintServers, Rect bounds) {
  final Offset offset = new Offset(
      double.parse(getAttribute(el, 'x', def: '0')),
      double.parse(getAttribute(el, 'y', def: '0')));

  return new DrawableText(
    el.text,
    offset,
    new DrawableStyle(
      groupOpacity: parseOpacity(el),
      textStyle: new TextStyle(
        fontFamily: getAttribute(el, 'font-family'),
        fontSize: double.parse(getAttribute(el, 'font-size', def: '55')),
        color: parseColor(
          getAttribute(
            el,
            'fill',
            def: getAttribute(el, 'stroke', def: 'black'),
          ),
        ),
        height: -1.0,
      ),
    ),
  );
}

/// Parses an SVG <g> element.
Drawable parseSvgGroup(
    XmlElement el, Map<String, PaintServer> paintServers, Rect bounds) {
  final List<Drawable> children = <Drawable>[];
  final DrawableStyle style =
      parseStyle(el, paintServers, bounds, needsTransform: true);
  el.children.forEach((child) {
    if (child is XmlElement) {
      final Drawable el = parseSvgElement(child, paintServers, bounds, style);
      if (el != null) {
        children.add(el);
      }
    }
  });

  return new DrawableGroup(
      children,
      //TODO: when Dart2 is around use this instead of above
      // el.children
      //     .whereType<XmlElement>()
      //     .map((child) => new SvgBaseElement.fromXml(child)),
      style);
}

/// Parses style attributes or @style attribute.
///
/// Remember that @style attribute takes precedence.
DrawableStyle parseStyle(
    XmlElement el, Map<String, PaintServer> paintServers, Rect bounds,
    {bool needsTransform = false, Color defaultFillIfNotSpecified}) {
  final Matrix4 transform =
      needsTransform ? parseTransform(getAttribute(el, 'transform')) : null;

  return new DrawableStyle(
    transform: transform?.storage,
    stroke: parseStroke(el, bounds, paintServers),
    dashArray: parseDashArray(el),
    dashOffset: parseDashOffset(el),
    fill: parseFill(el, bounds, paintServers, defaultFillIfNotSpecified),
    pathFillType: parseFillRule(el),
    groupOpacity: parseOpacity(el),
  );
}
