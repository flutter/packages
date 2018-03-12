import 'dart:ui';
import 'package:meta/meta.dart';
import 'dart:typed_data';

import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';
import 'parsers.dart';

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
    'title': (el) => const SvgNoop(),
    'desc': (el) => const SvgNoop(),
  };

  const SvgBaseElement();

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
  const TransformableSvgElement(this.transform);

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
  const SvgNoop();

  void draw(Canvas canvas) {}
}

class SvgCircle extends TransformableSvgElement {
  final double cx;
  final double cy;
  final double r;
  final Paint paint;

  const SvgCircle(this.cx, this.cy, this.r, this.paint, Matrix4 transform) : super(transform);

  factory SvgCircle.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final r = double.parse(el.getAttribute('r'));
    final fill = parseColor(el.getAttribute('fill'));
    final opacity = double.parse(el.getAttribute('opacity'));
    final paint = new Paint()..color = fill.withAlpha((255 * opacity).toInt());
    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgCircle(cx, cy, r, paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    canvas.drawCircle(new Offset(cx, cy), r, paint);
  }
}

class SvgGroup extends TransformableSvgElement {
  final List<SvgBaseElement> children;
  const SvgGroup(this.children, Matrix4 transform) : super(transform);

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
      transform
    );
  }

  @override
  void _innerDraw(Canvas canvas) {
    children.forEach((child) => child.draw(canvas));
  }
}

class SvgPath extends TransformableSvgElement {
  final Path path;
  final Paint paint;
  final Matrix4 transform;
  const SvgPath(this.path, this.paint, {this.transform}) : super(transform);

  factory SvgPath.fromXml(XmlElement el) {
    final d = el.getAttribute('d');
    final p = Path.parseSvgPathData(d);
    final fill = parseColor(el.getAttribute('fill'));
    final paint = new Paint()..color = fill;

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPath(p, paint, transform: transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    canvas.drawPath(path, paint);
  }
}

class SvgRect extends TransformableSvgElement {
  final Rect rect;
  final Paint paint;
  const SvgRect(this.rect, this.paint, Matrix4 transform) : super(transform);

  factory SvgRect.fromXml(XmlElement el) {
    final x = double.parse(el.getAttribute('x'));
    final y = double.parse(el.getAttribute('y'));
    final w = double.parse(el.getAttribute('width'));
    final h = double.parse(el.getAttribute('height'));

    final transform = parseTransform(el.getAttribute('transform'));
    final paint = new Paint()..color = parseColor(el.getAttribute('fill'));
    return new SvgRect(new Rect.fromLTWH(x, y, w, h), paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}

class SvgPolygon extends TransformableSvgElement {
  final Path path;
  final Paint paint;

  const SvgPolygon(this.path, this.paint, Matrix4 transform) : super(transform);

  factory SvgPolygon.fromXml(XmlElement el) {
    // flutter draws polygons without filling them.  Convert to path.
    final path = Path.parseSvgPathData('M' + el.getAttribute('points') + 'z');
    final paint = new Paint()
      ..color = parseColor(el.getAttribute('fill'))
      ..style = PaintingStyle.fill;


    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPolygon(path, paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    //canvas.drawRawPoints(PointMode.polygon, points, paint);
    canvas.drawPath(path, paint);
  }
}

class SvgPolyline extends TransformableSvgElement {
  final Path path;
  final Paint paint;

  const SvgPolyline(this.path, this.paint, Matrix4 transform) : super(transform);

  factory SvgPolyline.fromXml(XmlElement el) {
    // flutter draws polygons without filling them.  Convert to path.
    final path = Path.parseSvgPathData('M' + el.getAttribute('points'));
    final paint = new Paint()
      ..color = parseColor(el.getAttribute('fill'))
      ..style = PaintingStyle.fill;


    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPolyline(path, paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    //canvas.drawRawPoints(PointMode.polygon, points, paint);
    canvas.drawPath(path, paint);
  }
}
class SvgEllipse extends TransformableSvgElement {
  final Rect boundingRect;
  final Paint paint;

  const SvgEllipse(this.boundingRect, this.paint, Matrix4 transform) : super(transform);

  factory SvgEllipse.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final rx = double.parse(el.getAttribute('rx'));
    final ry = double.parse(el.getAttribute('ry'));
    final fill = parseColor(el.getAttribute('fill'));
    //final opacity = double.parse(el.getAttribute('opacity'));
    final paint = new Paint()..color = fill; //.withAlpha((255 * opacity).toInt());

    Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgEllipse(r, paint, transform);
  }

  @override
  void _innerDraw(Canvas canvas) {
    canvas.drawOval(boundingRect, paint);
  }
}
