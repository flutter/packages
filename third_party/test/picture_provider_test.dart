import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockPictureInfo extends Mock implements PictureInfo {}

class MockFile extends Mock implements File {}

void main() {
  group('PictureProvider', () {
    Color? currentColor;

    PictureInfoDecoder<T> decoderBuilder<T>(Color? color) {
      currentColor = color;
      return (T bytes, ColorFilter? colorFilter, String key) async =>
          MockPictureInfo();
    }

    test(
        'NetworkPicture rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () async {
      const Color color = Color(0xFFB0E3BE);
      final NetworkPicture networkPicture =
          NetworkPicture(decoderBuilder, 'url');

      final PictureInfoDecoder<Uint8List> decoder = networkPicture.decoder;

      expect(decoder, isNotNull);

      // Update the currentColor of PictureProvider.
      networkPicture.currentColor = color;

      expect(
        decoder,
        isNot(equals(networkPicture.decoder)),
      );

      expect(
        currentColor,
        equals(color),
      );
    });

    test(
        'FilePicture rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () async {
      const Color color = Color(0xFFB0E3BE);
      final FilePicture filePicture = FilePicture(decoderBuilder, MockFile());

      final PictureInfoDecoder<Uint8List> decoder = filePicture.decoder;

      expect(decoder, isNotNull);

      // Update the currentColor of PictureProvider.
      filePicture.currentColor = color;

      expect(
        decoder,
        isNot(equals(filePicture.decoder)),
      );

      expect(
        currentColor,
        equals(color),
      );
    });

    test(
        'MemoryPicture rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () async {
      const Color color = Color(0xFFB0E3BE);
      final MemoryPicture memoryPicture =
          MemoryPicture(decoderBuilder, Uint8List(0));

      final PictureInfoDecoder<Uint8List> decoder = memoryPicture.decoder;

      expect(decoder, isNotNull);

      // Update the currentColor of PictureProvider.
      memoryPicture.currentColor = color;

      expect(
        decoder,
        isNot(equals(memoryPicture.decoder)),
      );

      expect(
        currentColor,
        equals(color),
      );
    });

    test(
        'StringPicture rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () async {
      const Color color = Color(0xFFB0E3BE);
      final StringPicture stringPicture = StringPicture(decoderBuilder, '');

      final PictureInfoDecoder<String> decoder = stringPicture.decoder;

      expect(decoder, isNotNull);

      // Update the currentColor of PictureProvider.
      stringPicture.currentColor = color;

      expect(
        decoder,
        isNot(equals(stringPicture.decoder)),
      );

      expect(
        currentColor,
        equals(color),
      );
    });

    test(
        'ExactAssetPicture rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () async {
      const Color color = Color(0xFFB0E3BE);
      final ExactAssetPicture exactAssetPicture =
          ExactAssetPicture(decoderBuilder, '');

      final PictureInfoDecoder<String> decoder = exactAssetPicture.decoder;

      expect(decoder, isNotNull);

      // Update the currentColor of PictureProvider.
      exactAssetPicture.currentColor = color;

      expect(
        decoder,
        isNot(equals(exactAssetPicture.decoder)),
      );

      expect(
        currentColor,
        equals(color),
      );
    });

    test('Evicts from cache when currentColor changes', () async {
      expect(PictureProvider.cache.count, 0);
      const Color color = Color(0xFFB0E3BE);
      final StringPicture stringPicture = StringPicture(decoderBuilder, '');

      final PictureStream stream =
          stringPicture.resolve(createLocalPictureConfiguration(null));

      await null;
      expect(PictureProvider.cache.count, 1);

      stringPicture.currentColor = color;
      expect(PictureProvider.cache.count, 0);
    });
  });
}
