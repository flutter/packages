import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';

import 'vector_painter.dart';
import 'svg/parsers.dart';
import 'svg/xml_parsers.dart';

typedef DrawableSvgShape SvgShapeFactory(
    XmlElement el, Map<String, PaintServer> paintServers);

final Map<String, SvgShapeFactory> _shapes = {
  'circle': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgCircle(el, paintServers),
  'path': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgPath(el, paintServers),
  'rect': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgRect(el, paintServers),
  'polygon': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgPolygonOrLine(el, paintServers),
  'polyline': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgPolygonOrLine(el, paintServers),
  'ellipse': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgEllipse(el, paintServers),
  'line': (XmlElement el, Map<String, PaintServer> paintServers) =>
      new DrawableSvgShape.fromSvgLine(el, paintServers),
};

/// An SVG Shape element that will be drawn to the canvas.
class DrawableSvgShape extends DrawableShape {
  const DrawableSvgShape(Path path, Size size, {Paint stroke, Paint fill})
      : super(path, size, stroke: stroke, fill: fill);

  /// Applies the transformation in the @transform attribute to the path.
  static Path transformPath(Path path, XmlElement el) {
    assert(path != null);
    assert(el != null);

    final Matrix4 transform = parseTransform(el.getAttribute('transform'));

    if (transform != null) {
      return path.transform(transform.storage);
    } else {
      return path;
    }
  }

  static _createDrawable(Path path, Size size,
      Map<String, PaintServer> paintServers, XmlElement el) {
    final stroke = parseStroke(el, size, paintServers);
    final fill = parseFill(el, size, paintServers);

    return new DrawableSvgShape(transformPath(path, el), size,
        stroke: stroke, fill: fill);
  }

  /// Creates a [DrawableSvgShape] from an SVG <circle> element.
  factory DrawableSvgShape.fromSvgCircle(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final r = double.parse(el.getAttribute('r'));
    final oval = new Rect.fromCircle(center: new Offset(cx, cy), radius: r);
    final path = new Path()..addOval(oval);

    return _createDrawable(path, oval.size, paintServers, el);
  }

  /// Creates a [DrawableSvgShape] from an SVG <path> element.
  factory DrawableSvgShape.fromSvgPath(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final d = el.getAttribute('d');
    final Path path = parseSvgPathData(d);
    return _createDrawable(path, path.getBounds().size, paintServers, el);
  }

  /// Creates a [DrawableSvgShape] from an SVG <rect> element.
  factory DrawableSvgShape.fromSvgRect(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final double x = double.parse(el.getAttribute('x'));
    final double y = double.parse(el.getAttribute('y'));
    final double w = double.parse(el.getAttribute('width'));
    final double h = double.parse(el.getAttribute('height'));
    final Rect rect = new Rect.fromLTWH(x, y, w, h);
    String rxRaw = el.getAttribute('rx');
    String ryRaw = el.getAttribute('ry');
    rxRaw ??= ryRaw;
    ryRaw ??= rxRaw;

    if ((rxRaw != null && rxRaw != '')) {
      final double rx = double.parse(rxRaw);
      final double ry = double.parse(ryRaw);

      return _createDrawable(
        new Path()..addRRect(new RRect.fromRectXY(rect, rx, ry)),
        rect.size,
        paintServers,
        el,
      );
    }

    final path = new Path()..addRect(rect);
    return _createDrawable(path, rect.size, paintServers, el);
  }

  /// Creates a [DrawableSvgShape] from an SVG <polyline> or <polyline> element.
  factory DrawableSvgShape.fromSvgPolygonOrLine(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final path = parseSvgPathData('M' + el.getAttribute('points') + 'z');

    return _createDrawable(path, path.getBounds().size, paintServers, el);
  }

  /// Creates a [DrawableSvgShape] from an SVG <ellipse> element.
  factory DrawableSvgShape.fromSvgEllipse(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final rx = double.parse(el.getAttribute('rx'));
    final ry = double.parse(el.getAttribute('ry'));

    Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);

    return _createDrawable(new Path()..addOval(r), r.size, paintServers, el);
  }

  /// Creates a [DrawableSvgShape] from an SVG <line> element.
  factory DrawableSvgShape.fromSvgLine(
      XmlElement el, Map<String, PaintServer> paintServers) {
    final x1 = double.parse(el.getAttribute('x1'));
    final x2 = double.parse(el.getAttribute('x2'));
    final y1 = double.parse(el.getAttribute('y1'));
    final y2 = double.parse(el.getAttribute('y2'));

    final path = new Path()
      ..moveTo(x1, x2)
      ..lineTo(y1, y2);
    return _createDrawable(path, path.getBounds().size, paintServers, el);
  }
}

/// Creates a [Drawable] from an SVG <g> or shape element.  Also handles parsing <defs> and gradients.
///
/// If an unsupported element is encountered, it will be created as a [DrawableNoop].
Drawable parseSvgElement(
    XmlElement el, Map<String, PaintServer> paintServers, Size size) {
  final SvgShapeFactory shapeFn = _shapes[el.name.local];
  if (shapeFn != null) {
    return shapeFn(el, paintServers);
  } else if (el.name.local == 'defs') {
    parseDefs(el, paintServers, size);
  } else if (el.name.local == 'g') {
    return parseSvgGroup(el, paintServers, size);
  }
  if (el.name.local == 'svg') {
    throw new UnsupportedError(
        'Nested SVGs not supported in this implementation.');
  }
  print('Unhandled element ${el.name.local}');
  return new DrawableNoop(el.name.local);
}

/// Parses an SVG <g> element.
Drawable parseSvgGroup(
    XmlElement el, Map<String, PaintServer> paintServers, Size size) {
  final List<Drawable> children = <Drawable>[];
  el.children.forEach((child) {
    if (child is XmlElement) {
      final Drawable el = parseSvgElement(child, paintServers, size);
      if (el != null) {
        children.add(el);
      }
    }
  });

  final Matrix4 transform = parseTransform(el.getAttribute('transform'));
  final Paint fill = parseFill(el, size, paintServers, isShape: false);
  final Paint stroke = parseStroke(el, size, paintServers);

  return new DrawableGroup(
    children,
    //TODO: when Dart2 is around use this instead of above
    // el.children
    //     .whereType<XmlElement>()
    //     .map((child) => new SvgBaseElement.fromXml(child)),
    transform?.storage, stroke, fill,
  );
}
