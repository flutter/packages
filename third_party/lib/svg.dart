import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/src/svg_painter.dart';
import 'package:xml/xml.dart';


class SvgImage extends StatelessWidget {
  final Size size;
  final XmlDocument _rawSvg;

  const SvgImage(this._rawSvg, this.size, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return new CustomPaint(
              painter: new SvgPainter(_rawSvg), size: size);
  }
}
