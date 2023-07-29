import 'package:camera_platform_interface/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$ImageFormat tests', () {
    test('ImageFormat extension returns correct values', () {
      expect(ImageFormat.jpeg.name, 'jpeg');
      expect(ImageFormat.heic.name, 'heic');
    });

    test('ImageFormat serialization', () {
      expect(serializeImageFormat(ImageFormat.jpeg), 'jpeg');
      expect(serializeImageFormat(ImageFormat.heic), 'heic');
    });

    test('ImageFormat deserialization', () {
      expect(deserializeImageFormat('jpeg'), ImageFormat.jpeg);
      expect(deserializeImageFormat('heic'), ImageFormat.heic);
      expect(() => deserializeImageFormat('invalid'), throwsArgumentError);
    });
  });
}
