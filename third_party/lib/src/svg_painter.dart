import 'dart:typed_data';

import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart';

import 'elements.dart';
import 'gradients.dart';
import 'parsers/xml_parsers.dart';

class SvgPainter extends CustomPainter {
  final XmlDocument _rawSvg;
  final bool _clipToViewBox;

  SvgPainter(String rawSvg, {bool clipToViewBox = true})
      : _rawSvg = parse(rawSvg),
        _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    if (_rawSvg == null) return;

    final Rect vbRect = parseViewBox(_rawSvg.rootElement);

    final double xscale = size.width / vbRect.size.width;
    final double yscale = size.height / vbRect.size.height;

    if (xscale == yscale) {
      canvas.scale(xscale, yscale);
    } else if (xscale < yscale) {
      final double xtranslate = (vbRect.size.width - vbRect.size.height) / 2;
      canvas.scale(xscale, xscale);
      canvas.translate(0.0, xtranslate);
    } else {
      final double ytranslate = (vbRect.size.height - vbRect.size.width) / 2;
      canvas.scale(yscale, yscale);
      canvas.translate(ytranslate, 0.0);
    }

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
