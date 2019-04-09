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

import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/src/vector_drawable.dart';

Future<Uint8List> getSvgPngBytes(String svgData) async {
  final PictureRecorder rec = PictureRecorder();
  final Canvas canvas = Canvas(rec);

  const Size size = Size(200.0, 200.0);

  final DrawableRoot svgRoot =
      await svg.fromSvgString(svgData, 'GenGoldenTest');
  svgRoot.scaleCanvasToViewBox(canvas, size);
  svgRoot.clipCanvasToViewBox(canvas);

  canvas.drawPaint(Paint()..color = const Color(0xFFFFFFFF));
  svgRoot.draw(canvas, null, svgRoot.viewport.viewBoxRect);

  final Picture pict = rec.endRecording();

  final Image image =
      await pict.toImage(size.width.toInt(), size.height.toInt());
  final ByteData bytes = await image.toByteData(format: ImageByteFormat.png);

  return bytes.buffer.asUint8List();
}

Iterable<File> getSvgFileNames() sync* {
  final Directory dir = Directory('./example/assets');
  for (FileSystemEntity fe in dir.listSync(recursive: true)) {
    if (fe is File && fe.path.toLowerCase().endsWith('.svg')) {
      // Skip text based tests unless we're on Linux - these have
      // subtle platform specific differences.
      if (fe.path.toLowerCase().contains('text') && !Platform.isLinux) {
        continue;
      }
      yield fe;
    }
  }
}

String getGoldenFileName(String svgAssetPath) {
  return svgAssetPath
      .replaceAll('/example\/assets/', '/golden/')
      .replaceAll('\\example\\assets\\', '\\golden\\')
      .replaceAll('.svg', '.png');
}

Future<void> main() async {
  for (File fe in getSvgFileNames()) {
    final String pathName = getGoldenFileName(fe.path);

    final Directory goldenDir = Directory(path.dirname(pathName));
    if (!goldenDir.existsSync()) {
      goldenDir.createSync(recursive: true);
    }
    final File output = File(pathName);
    print(pathName);
    await output.writeAsBytes(await getSvgPngBytes(await fe.readAsString()));
  }
}
