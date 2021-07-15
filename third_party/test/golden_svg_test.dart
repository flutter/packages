import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path/path.dart';

import 'package:test/test.dart';

import '../tool/gen_golden.dart' as golden;

Iterable<File> getGoldenFileNames() sync* {
  final String root = dirname(Platform.script.toFilePath());
  final Directory dir =
      Directory(join(root, root.endsWith('test') ? '..' : '', 'golden'));
  for (FileSystemEntity fe in dir.listSync(recursive: true)) {
    if (fe is File && fe.path.toLowerCase().endsWith('.png')) {
      if (fe.path.toLowerCase().contains('text') && !Platform.isLinux) {
        continue;
      }
      yield fe;
    }
  }
}

String getSvgAssetName(String goldenFileName) {
  return goldenFileName
      .replaceAll('/golden/', '/example/assets/')
      .replaceAll('\\golden\\', '\\example\\assets\\')
      .replaceAll('.png', '.svg');
}

bool colorComponentsSimilar(int a, int b) => (a - b).abs() <= 1;

void main() {
  test('SVG Rendering matches golden files', () async {
    for (File goldenFile in getGoldenFileNames()) {
      final File svgAssetFile = File(getSvgAssetName(goldenFile.path));
      final Uint8List bytes =
          await golden.getSvgRgbaBytes(await svgAssetFile.readAsString());

      final Codec testImageCodec =
          await instantiateImageCodec(await goldenFile.readAsBytes());
      final Image testImage = (await testImageCodec.getNextFrame()).image;
      final ByteData? goldenRgba =
          await testImage.toByteData(format: ImageByteFormat.rawRgba);
      final Uint8List goldenBytes = goldenRgba!.buffer.asUint8List();

      expect(
          bytes,
          pairwiseCompare(goldenBytes, colorComponentsSimilar,
              'components nearly equal to'),
          reason:
              '${goldenFile.path} does not match rendered output of ${svgAssetFile.path}!');
    }
  }, skip: !Platform.isLinux);
}
