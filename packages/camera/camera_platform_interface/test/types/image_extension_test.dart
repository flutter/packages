import 'package:camera_platform_interface/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$ImageExtension tests', () {
    test('ImageFormat extension returns correct values', () {
      expect(ImageExtension.jpeg.name, 'jpeg');
      expect(ImageExtension.heic.name, 'heic');
    });

    test('ImageExtensiont serialization', () {
      expect(serializeImageExtension(ImageExtension.jpeg), 'jpeg');
      expect(serializeImageExtension(ImageExtension.heic), 'heic');
    });

    test('ImageExtension deserialization', () {
      expect(deserializeImageExtension('jpeg'), ImageExtension.jpeg);
      expect(deserializeImageExtension('heic'), ImageExtension.heic);
      expect(() => deserializeImageExtension('invalid'), throwsArgumentError);
    });
  });
}
