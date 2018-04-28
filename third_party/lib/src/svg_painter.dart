import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart';

import 'elements.dart';
import 'gradients.dart';
import 'parsers/parsers.dart';
import 'parsers/xml_parsers.dart';


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
    final Map<String, PaintServer> paintServers = <String, PaintServer>{};

    for (var el in _rawSvg.rootElement.children) {
      if (el is XmlElement) {
        if (el.name.local == 'defs') {
          parseDefs(el, paintServers, size);
        } else {
          new SvgElement.fromXml(el, paintServers, size).draw(canvas);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SvgPainter oldPainter) =>
      _rawSvg != null && oldPainter._rawSvg != _rawSvg;
}
