import 'package:camera_platform_interface/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$ImageExtension tests', () {
    test('ImageFormat extension returns correct values', () {
      expect(ImageExtension.jpeg.name(), 'jpeg');
      expect(ImageExtension.heic.name(), 'heic');
    });
  });
}
