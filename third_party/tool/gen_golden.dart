// There's probably some better way to do this, but for now run `flutter test tool/gen_golden.dart
// should exclude files that
// - aren't rendering properly
// - have text (this doesn't render properly in the host setup?)
// The golden files should then be visually compared against Chrome's rendering output for correctness.
// The comparison may have to be made more tolerant if we want to use other sources of rendering for comparison...

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path/path.dart' as path;

import 'package:flutter_svg/svg.dart' as svg;
import 'package:flutter_svg/src/vector_painter.dart';

Future<Uint8List> getSvgPngBytes(String svgData) async {
  final PictureRecorder rec = new PictureRecorder();
  final Canvas canvas = new Canvas(rec);

  const Size size = const Size(200.0, 200.0);

  final DrawableRoot svgRoot = svg.fromSvgString(svgData, size);
  svgRoot.scaleCanvasToViewBox(canvas, size);
  svgRoot.clipCanvasToViewBox(canvas);

  canvas.drawPaint(new Paint()..color = const Color(0xFFFFFFFF));
  svgRoot.draw(canvas);

  final Picture pict = rec.endRecording();

  final Image image = pict.toImage(size.width.toInt(), size.height.toInt());
  final ByteData bytes = await image.toByteData(format: ImageByteFormat.png);

  return bytes.buffer.asUint8List();
}

final Set<String> badSvgFiles = new Set<String>.of(<String>[
  'simple/text.svg',
]);

Iterable<File> getSvgFileNames() sync* {
  final Directory dir = new Directory('./assets');
  for (FileSystemEntity fe in dir.listSync(recursive: true)) {
    if (fe is File &&
        fe.path.toLowerCase().endsWith('.svg') &&
        !badSvgFiles.contains(fe.path
            .substring(fe.path.lastIndexOf(new RegExp(r'[\\/]assets')) + 8))) {
      yield fe;
    }
  }
}


String getGoldenFileName(String svgAssetPath) {
  return svgAssetPath
      .replaceAll('/assets/', '/golden/')
      .replaceAll('\\assets\\', '\\golden\\')
      .replaceAll('.svg', '.png');
}

Future<Null> main() async {
  for (File fe in getSvgFileNames()) {
    final String pathName = getGoldenFileName(fe.path);

    final Directory goldenDir = new Directory(path.dirname(pathName));
    if (!goldenDir.existsSync()) {
      goldenDir.createSync(recursive: true);
    }
    final File output = new File(pathName);
    await output.writeAsBytes(await getSvgPngBytes(await fe.readAsString()));
  }
}
