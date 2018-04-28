import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';

import 'parsers/parsers.dart';
import 'parsers/xml_parsers.dart';

typedef Path SvgPathFactory(XmlElement el);
final Map<String, SvgPathFactory> _shapes = {
  'circle': (el) => pathFromSvgCircle(el),
  'path': (el) => pathFromSvgPath(el),
  'rect': (el) => pathFromSvgRect(el),
  'polygon': (el) => pathFromSvgPolygonOrLine(el),
  'polyline': (el) => pathFromSvgPolygonOrLine(el),
  'ellipse': (el) => pathFromSvgEllipse(el),
  'line': (el) => pathFromSvgLine(el),
};

class SvgElement {
  final String name;
  const SvgElement(this.name);
  void draw(Canvas canvas, [Paint parentPaint]) {}

  factory SvgElement.fromXml(XmlElement el, Map<String, Paint> paintServers) {
    if (el.name.local == 'g') {
      return new SvgGroup.fromXml(el, paintServers);
    } else if (_shapes.containsKey(el.name.local)) {
      return new SvgShape.fromXml(el, paintServers);
    }
    return new SvgElement(el.name.local);
  }
}

class SvgShape extends SvgElement {
  final Path path;
  final Paint stroke;
  final Paint fill;

  const SvgShape(this.path, this.stroke, this.fill, String elementName)
      : assert(path != null, '$elementName had a null path'),
        super(elementName);

  @override
  void draw(Canvas canvas, [Paint parentPaint]) {
    if (parentPaint != null) {
      canvas.drawPath(path, parentPaint);
      return;
    }
    if (stroke != null) canvas.drawPath(path, stroke);
    if (fill != null) canvas.drawPath(path, fill);
  }

  factory SvgShape.fromXml(XmlElement el, Map<String, Paint> paintServers) {
    final stroke = parseStroke(el);
    final fill = parseFill(el, paintServers);
    final ret = _shapes[el.name.local];

    return new SvgShape(ret(el), stroke, fill, el.name.local);
  }
}

class SvgGroup extends SvgElement {
  final List<SvgElement> children;
  final Paint stroke;
  final Paint fill;
  final Matrix4 transform;
  const SvgGroup(this.children, this.transform, this.stroke, this.fill)
      : super('g');

  factory SvgGroup.fromXml(XmlElement el, Map<String, Paint> paintServers) {
    var children = new List<SvgElement>();
    el.children.forEach((child) {
      if (child is XmlElement) {
        final SvgElement el = new SvgElement.fromXml(child, paintServers);
        if (el != null) {
          children.add(el);
        }
      }
    });

    final transform = parseTransform(el.getAttribute('transform'));
    final fill = parseFill(el, paintServers, isShape: false);
    final stroke = parseStroke(el);

    return new SvgGroup(
      children,
      //TODO: when Dart2 is around use this instead of above
      // el.children
      //     .whereType<XmlElement>()
      //     .map((child) => new SvgBaseElement.fromXml(child)),
      transform, stroke, fill,
    );
  }

  @override
  void draw(Canvas canvas, [Paint parentPaint]) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform.storage);
    }
    children.forEach((child) {
      if (stroke != null) {
        child.draw(canvas, stroke);
      }
      if (fill != null) {
        child.draw(canvas, fill);
      }
      if (stroke == null && fill == null) {
        child.draw(canvas);
      }
    });
    if (transform != null) {
      canvas.restore();
    }
  }
}

Path transformPath(Path path, XmlElement el) {
  assert(path != null);
  assert(el != null);

  final transform = parseTransform(el.getAttribute('transform'));

  if (transform != null) {
    return path.transform(transform.storage);
  } else {
    return path;
  }
}

Path pathFromSvgCircle(XmlElement el) {
  final cx = double.parse(el.getAttribute('cx'));
  final cy = double.parse(el.getAttribute('cy'));
  final r = double.parse(el.getAttribute('r'));

  final path = new Path()
    ..addOval(new Rect.fromCircle(center: new Offset(cx, cy), radius: r));
  return transformPath(path, el);
}

Path pathFromSvgPath(XmlElement el) {
  final d = el.getAttribute('d');
  final Path p = parseSvgPathData(d);
  return transformPath(p, el);
}

Path pathFromSvgRect(XmlElement el) {
  final double x = double.parse(el.getAttribute('x'));
  final double y = double.parse(el.getAttribute('y'));
  final double w = double.parse(el.getAttribute('width'));
  final double h = double.parse(el.getAttribute('height'));
  final Rect rect = new Rect.fromLTWH(x, y, w, h);
  String rxRaw = el.getAttribute('rx');
  String ryRaw = el.getAttribute('ry');
  rxRaw ??= ryRaw;
  ryRaw ??= rxRaw;

  if ((rxRaw != null && rxRaw != "")) {
    final double rx = double.parse(rxRaw);
    final double ry = double.parse(ryRaw);
    return transformPath(
        new Path()..addRRect(new RRect.fromRectXY(rect, rx, ry)), el);
  }

  final path = new Path()..addRect(rect);
  return transformPath(path, el);
}

Path pathFromSvgPolygonOrLine(XmlElement el) {
  final path = parseSvgPathData('M' + el.getAttribute('points') + 'z');

  return transformPath(path, el);
}

Path pathFromSvgEllipse(XmlElement el) {
  final cx = double.parse(el.getAttribute('cx'));
  final cy = double.parse(el.getAttribute('cy'));
  final rx = double.parse(el.getAttribute('rx'));
  final ry = double.parse(el.getAttribute('ry'));

  Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);

  return transformPath(new Path()..addOval(r), el);
}

Path pathFromSvgLine(XmlElement el) {
  final x1 = double.parse(el.getAttribute('x1'));
  final x2 = double.parse(el.getAttribute('x2'));
  final y1 = double.parse(el.getAttribute('y1'));
  final y2 = double.parse(el.getAttribute('y2'));

  final path = new Path()
    ..moveTo(x1, x2)
    ..lineTo(y1, y2);
  return transformPath(path, el);
}
