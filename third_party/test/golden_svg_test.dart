import 'dart:io';
import 'dart:typed_data';

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

void main() {
  test('SVG Rendering matches golden files', () async {
    for (File goldenFile in getGoldenFileNames()) {
      final File svgAssetFile = File(getSvgAssetName(goldenFile.path));
      final Uint8List bytes =
          await golden.getSvgPngBytes(await svgAssetFile.readAsString());

      final Uint8List goldenBytes = await goldenFile.readAsBytes();

      expect(bytes, orderedEquals(goldenBytes),
          reason:
              '${goldenFile.path} does not match rendered output of ${svgAssetFile.path}!');
    }
  }, skip: !Platform.isLinux);
}
