import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/src/svg_painter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:xml/xml.dart';

class SvgImage extends StatelessWidget {
  final Size size;
  final Future<XmlDocument> future;

  const SvgImage._(this.future, this.size, {Key key}) : super(key: key);

  factory SvgImage.fromAsset(String assetName, Size size, {Key key}) {
    return new SvgImage._(
      loadAsset(assetName),
      size,
      key: key,
    );
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: ((context, snapShot) {
        if (snapShot.hasData) {
          return new CustomPaint(
              painter: new SvgPainter(snapShot.data), size: size);
        }
        return new LimitedBox();
      }),
    );
  }
}

Future<XmlDocument> loadAsset(String assetName) async {
  final xml = await rootBundle.loadString(assetName);
  return parse(xml);
}
