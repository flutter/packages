import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/src/parsers.dart';
import 'package:flutter_svg/src/elements.dart';

class SvgPainter extends CustomPainter {
  final XmlDocument _rawSvg;

  SvgPainter(this._rawSvg);

  @override
  void paint(Canvas canvas, Size size) {
    if (_rawSvg == null) return;
    var viewBox =
        (_rawSvg.root.firstChild as XmlElement).getAttribute('viewBox');
    final vbRect = parseViewBox(viewBox);
    canvas.scale(size.width / vbRect.size.width, size.height / vbRect.size.height);
    for (var el in _rawSvg.root.firstChild.children) {
      if (el is! XmlElement) continue;
      final svgEl = new SvgBaseElement.fromXml(el);
      svgEl.draw(el, canvas);
    }
  }

  @override
  bool shouldRepaint(SvgPainter oldPainter) =>
      _rawSvg != null && oldPainter._rawSvg != _rawSvg;
}
