import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';
import 'parsers.dart';

typedef SvgBaseElement SvgElementFactory(XmlElement el);

abstract class SvgBaseElement {
  final XmlElement _rawElement;

  static final Map<String, SvgElementFactory> _elements = {
    'circle': (el) => new SvgCircle(el),
    'path': (el) => new SvgPath(el),
  };

  void draw(XmlElement element, Canvas canvas);

  const SvgBaseElement._(this._rawElement);

  factory SvgBaseElement.fromXml(XmlElement element) {
    final ret = _elements[element.name.local];
    if (ret == null) {
      throw new UnsupportedError('${element.name.local} not impleemnted yet');
    }

    return ret(element);
  }
}

class SvgCircle extends SvgBaseElement {
  const SvgCircle(XmlElement el) : super._(el);

  void draw(XmlElement el, Canvas canvas) {
    final cx = double.parse(el.getAttribute('cx'));
    final cy = double.parse(el.getAttribute('cy'));
    final r = double.parse(el.getAttribute('r'));
    final fill = parseColor(el.getAttribute('fill'));
    final opacity = double.parse(el.getAttribute('opacity'));
    final paint = new Paint()..color = fill.withAlpha((255 * opacity).toInt());
    canvas.drawCircle(new Offset(cx, cy), r, paint);
  }
}

class SvgPath extends SvgBaseElement {
  const SvgPath(XmlElement el) : super._(el);

  void draw(XmlElement el, Canvas canvas) {
    final d = el.getAttribute('d');
    final p = Path.parseSvgPathData(d);
    final fill = parseColor(el.getAttribute('fill'));
    final paint = new Paint()..color = fill;
    // TODO: Actually implement a parser for this
    // Maybe take logic from https://github.com/flutter/flutter/blob/master/dev/tools/vitool/lib/vitool.dart
    if (el.getAttribute('transform') != null) {
      final m = new Matrix4.identity();
      m.scale(0.1);
      p.transform(m.storage);
      canvas.scale(.1, .1);
    }
    canvas.drawPath(p, paint);

  }
}
