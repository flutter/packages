import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';
import 'parsers/parsers.dart';
import 'parsers/xml_parsers.dart';

typedef SvgBaseElement SvgElementFactory(XmlElement el);

abstract class SvgBaseElement {
  static final Map<String, SvgElementFactory> _elements = {
    'circle': (el) => new SvgCircle.fromXml(el),
    'path': (el) => new SvgPath.fromXml(el),
    'g': (el) => new SvgGroup.fromXml(el),
    'rect': (el) => new SvgRect.fromXml(el),
    'polygon': (el) => new SvgPolygon.fromXml(el),
    'polyline': (el) => new SvgPolyline.fromXml(el),
    'ellipse': (el) => new SvgEllipse.fromXml(el),
    'line': (el) => new SvgLine.fromXml(el),
    'title': (el) => const SvgNoop(),
    'desc': (el) => const SvgNoop(),
  };

  final Paint stroke;
  final Paint fill;
  const SvgBaseElement(this.stroke, this.fill);

  void draw(Canvas canvas);

  factory SvgBaseElement.fromXml(XmlElement element) {
    final ret = _elements[element.name.local];
    if (ret == null) {
      throw new UnsupportedError('${element.name.local} not impleemnted yet');
    }

    return ret(element);
  }
}

abstract class TransformableSvgElement extends SvgBaseElement {
  final Matrix4 transform;
  const TransformableSvgElement(this.transform, Paint stroke, Paint fill)
      : super(stroke, fill);

  @override
  void draw(Canvas canvas) {
    _startTransform(canvas);
    _innerDraw(canvas);
    _closeTransform(canvas);
  }

  void _innerDraw(Canvas canvas);

  void _startTransform(Canvas canvas) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform.storage);
    }
  }

  void _closeTransform(Canvas canvas) {
    if (transform != null) {
      canvas.restore();
    }
  }
}

class SvgNoop extends SvgBaseElement {
  const SvgNoop() : super(null, null);

  void draw(Canvas canvas) {}
}

class SvgCircle extends TransformableSvgElement {
  final Offset center;
  final double r;

  const SvgCircle(
      this.center, this.r, Paint stroke, Paint fill, Matrix4 transform)
      : super(transform, stroke, fill);

  factory SvgCircle.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final r = double.parse(el.getAttribute('r'));
    final stroke = parseStroke(el);
    final fill = parseFill(el);
    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgCircle(new Offset(cx, cy), r, stroke, fill, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    if (stroke != null) canvas.drawCircle(center, r, stroke);
    if (fill != null) canvas.drawCircle(center, r, fill);
  }
}

class SvgGroup extends TransformableSvgElement {
  final List<SvgBaseElement> children;
  const SvgGroup(this.children, Matrix4 transform)
      : super(transform, null, null);

  factory SvgGroup.fromXml(XmlElement el) {
    var children = new List<SvgBaseElement>();
    el.children.forEach((child) {
      if (child is XmlElement) {
        children.add(new SvgBaseElement.fromXml(child));
      }
    });

    final transform = parseTransform(el.getAttribute('transform'));

    return new SvgGroup(
        children,
        //TODO: when Dart2 is around use this instead of above
        // el.children
        //     .whereType<XmlElement>()
        //     .map((child) => new SvgBaseElement.fromXml(child)),
        transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    children.forEach((child) => child.draw(canvas));
  }
}

class SvgPath extends TransformableSvgElement {
  final Path path;
  final Matrix4 transform;
  const SvgPath(this.path, Paint stroke, Paint fill, {this.transform})
      : super(transform, stroke, fill);

  factory SvgPath.fromXml(XmlElement el) {
    final d = el.getAttribute('d');
    final p = Path.parseSvgPathData(d);

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPath(p, parseStroke(el), parseFill(el), transform: transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    if (stroke != null) canvas.drawPath(path, stroke);
    if (fill != null) canvas.drawPath(path, fill);
  }
}

class SvgRect extends TransformableSvgElement {
  final Rect rect;
  const SvgRect(this.rect, Paint stroke, Paint fill, Matrix4 transform)
      : super(transform, stroke, fill);

  factory SvgRect.fromXml(XmlElement el) {
    final x = double.parse(el.getAttribute('x'));
    final y = double.parse(el.getAttribute('y'));
    final w = double.parse(el.getAttribute('width'));
    final h = double.parse(el.getAttribute('height'));

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgRect(new Rect.fromLTWH(x, y, w, h), parseStroke(el),
        parseFill(el), transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    if (stroke != null) canvas.drawRect(rect, stroke);
    if (fill != null) canvas.drawRect(rect, fill);
  }
}

class SvgPolygon extends TransformableSvgElement {
  final Path path;

  const SvgPolygon(this.path, Paint stroke, Paint fill, Matrix4 transform)
      : super(transform, stroke, fill);

  factory SvgPolygon.fromXml(XmlElement el) {
    // flutter draws polygons without filling them.  Convert to path.
    final path = Path.parseSvgPathData('M' + el.getAttribute('points') + 'z');

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPolygon(path, parseStroke(el), parseFill(el), transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    //canvas.drawRawPoints(PointMode.polygon, points, paint);
    if (stroke != null) canvas.drawPath(path, stroke);
    if (fill != null) canvas.drawPath(path, fill);
  }
}

class SvgPolyline extends TransformableSvgElement {
  final Path path;

  const SvgPolyline(this.path, Paint stroke, Paint fill, Matrix4 transform)
      : super(transform, stroke, fill);

  factory SvgPolyline.fromXml(XmlElement el) {
    // flutter draws polygons without filling them.  Convert to path.
    final path = Path.parseSvgPathData('M' + el.getAttribute('points'));

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPolyline(path, parseStroke(el), parseFill(el), transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    if (stroke != null) canvas.drawPath(path, stroke);
    if (fill != null) canvas.drawPath(path, fill);
  }
}

class SvgEllipse extends TransformableSvgElement {
  final Rect boundingRect;

  const SvgEllipse(
      this.boundingRect, Paint stroke, Paint fill, Matrix4 transform)
      : super(transform, stroke, fill);

  factory SvgEllipse.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final rx = double.parse(el.getAttribute('rx'));
    final ry = double.parse(el.getAttribute('ry'));

    Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgEllipse(r, parseStroke(el), parseFill(el), transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    if (stroke != null) canvas.drawOval(boundingRect, stroke);
    if (fill != null) canvas.drawOval(boundingRect, fill);
  }
}

class SvgLine extends TransformableSvgElement {
  final Offset start;
  final Offset end;

  const SvgLine(this.start, this.end, Paint stroke, Matrix4 transform)
      : super(transform, stroke, null);

  factory SvgLine.fromXml(XmlElement el) {
    final x1 = double.parse(el.getAttribute('x1'));
    final x2 = double.parse(el.getAttribute('x2'));
    final y1 = double.parse(el.getAttribute('y1'));
    final y2 = double.parse(el.getAttribute('y2'));
    final paint = parseStroke(el);

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgLine(
        new Offset(x1, x2), new Offset(y1, y2), paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    canvas.drawLine(start, end, stroke);
  }
}
