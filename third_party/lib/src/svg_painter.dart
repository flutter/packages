import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/src/parsers/parsers.dart';
import 'package:flutter_svg/src/elements.dart';

class SvgPainter extends CustomPainter {
  final XmlDocument _rawSvg;
  final bool _clipToViewBox;

  SvgPainter(this._rawSvg, {bool clipToViewBox = true})
      : _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    if (_rawSvg == null) return;

    var viewBox = _rawSvg.rootElement.getAttribute('viewBox');
    final vbRect = parseViewBox(viewBox);
    canvas.scale(
        size.width / vbRect.size.width, size.height / vbRect.size.height);
    
    if (_clipToViewBox) {
      canvas.clipRect(vbRect);
    }
    
    for (var el in _rawSvg.rootElement.children) {
      if (el is! XmlElement) continue;
      final svgEl = new SvgElement.fromXml(el);
      svgEl.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(SvgPainter oldPainter) =>
      _rawSvg != null && oldPainter._rawSvg != _rawSvg;
}
