import 'dart:ui';
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

  void _startTransform(Matrix4 transform, Canvas canvas) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform.storage);
    }
  }

  void _closeTransform(Matrix4 transform, Canvas canvas) {
    if (transform != null) {
      canvas.restore();
    }
  }
}

class SvgNoop extends SvgBaseElement {
  const SvgNoop();

  void draw(Canvas canvas) {}
}

class SvgCircle extends SvgBaseElement {
  final double cx;
  final double cy;
  final double r;
  final Paint paint;

  const SvgCircle(this.cx, this.cy, this.r, this.paint);

  factory SvgCircle.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final r = double.parse(el.getAttribute('r'));
    final fill = parseColor(el.getAttribute('fill'));
    final opacity = double.parse(el.getAttribute('opacity'));
    final paint = new Paint()..color = fill.withAlpha((255 * opacity).toInt());

    return new SvgCircle(cx, cy, r, paint);
  }

  void draw(Canvas canvas) {
    canvas.drawCircle(new Offset(cx, cy), r, paint);
  }
}

class SvgGroup extends SvgBaseElement {
  final List<SvgBaseElement> children;
  const SvgGroup(this.children);

  factory SvgGroup.fromXml(XmlElement el) {
    var children = new List<SvgBaseElement>();
    el.children.forEach((child) {
      if (child is XmlElement) {
        children.add(new SvgBaseElement.fromXml(child));
      }
    });
    return new SvgGroup(
      children,
      //TODO: when Dart2 is around use this
      // el.children
      //     .whereType<XmlElement>()
      //     .map((child) => new SvgBaseElement.fromXml(child)),
    );
  }

  void draw(Canvas canvas) {
    children.forEach((child) => child.draw(canvas));
  }
}

class SvgPath extends SvgBaseElement {
  final Path path;
  final Paint paint;
  final Matrix4 transform;
  const SvgPath(this.path, this.paint, {this.transform});

  factory SvgPath.fromXml(XmlElement el) {
    final d = el.getAttribute('d');
    final p = Path.parseSvgPathData(d);
    final fill = parseColor(el.getAttribute('fill'));
    final paint = new Paint()..color = fill;

    final transform = parseTransform(el.getAttribute('transform'));
    return new SvgPath(p, paint, transform: transform);
  }

  void draw(Canvas canvas) {
    _startTransform(transform, canvas);
    canvas.drawPath(path, paint);
    _closeTransform(transform, canvas);
  }
}

class SvgRect extends SvgBaseElement {
  final Rect rect;
  final Paint paint;
  const SvgRect(this.rect, this.paint);

  factory SvgRect.fromXml(XmlElement el) {
    final x = double.parse(el.getAttribute('x'));
    final y = double.parse(el.getAttribute('y'));
    final w = double.parse(el.getAttribute('width'));
    final h = double.parse(el.getAttribute('height'));

    final paint = new Paint()..color = parseColor(el.getAttribute('fill'));
    return new SvgRect(new Rect.fromLTWH(x, y, w, h), paint);
  }

  void draw(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}

class SvgPolygon extends SvgBaseElement {
  final Float32List points;
  final Paint paint;

  const SvgPolygon(this.points, this.paint);

  factory SvgPolygon.fromXml(XmlElement el) {
    final points = parsePoints(el.getAttribute('points'));
    final paint = new Paint()
      ..color = parseColor(el.getAttribute('fill'))
      ..style = PaintingStyle.fill;
    return new SvgPolygon(points, paint);
  }

  void draw(Canvas canvas) {
    canvas.drawRawPoints(PointMode.polygon, points, paint);
  }
}

class SvgEllipse extends SvgBaseElement {
  final Rect boundingRect;
  final Paint paint;

  const SvgEllipse(this.boundingRect, this.paint);

  factory SvgEllipse.fromXml(XmlElement el) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final rx = double.parse(el.getAttribute('rx'));
    final ry = double.parse(el.getAttribute('ry'));
    final fill = parseColor(el.getAttribute('fill'));
    //final opacity = double.parse(el.getAttribute('opacity'));
    final paint = new Paint()..color = fill; //.withAlpha((255 * opacity).toInt());

    Rect r = new Rect.fromLTWH(cx - (rx / 2), cy - (ry / 2), rx, ry);
    return new SvgEllipse(r, paint);
  }

  void draw(Canvas canvas) {
    canvas.drawOval(boundingRect, paint);
  }
}
