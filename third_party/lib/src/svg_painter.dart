import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/src/elements.dart';
import 'package:flutter_svg/src/parsers/parsers.dart';
import 'package:flutter_svg/src/parsers/xml_parsers.dart';

class SvgPainter extends CustomPainter {
  final _rawSvg;
  final bool _clipToViewBox;

  SvgPainter(String rawSvg, {bool clipToViewBox = true})
      : _rawSvg = parse(rawSvg),
        _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    if (_rawSvg == null) return;

    final String viewBox = _rawSvg.rootElement.getAttribute('viewBox') ??
        '0 0 '
        '${_rawSvg.rootElement.getAttribute('width') ?? '0'} '
        '${_rawSvg.rootElement.getAttribute('height') ?? '0'}';

    final vbRect = parseViewBox(viewBox);
    canvas.scale(
      size.width / vbRect.size.width,
      size.height / vbRect.size.height,
    );

    if (_clipToViewBox) {
      canvas.clipRect(vbRect.translate(vbRect.left, vbRect.top));
    }
    final Map<String, Paint> paintServers = <String, Paint>{};

    for (var el in _rawSvg.rootElement.children) {
      if (el is XmlElement) {
        if (el.name.local == 'defs') {
          parseDefs(el, paintServers);
        } else {
          new SvgElement.fromXml(el, paintServers).draw(canvas);
        }
      }
    }
    print(paintServers);
  }

  @override
  bool shouldRepaint(SvgPainter oldPainter) =>
      _rawSvg != null && oldPainter._rawSvg != _rawSvg;
}
