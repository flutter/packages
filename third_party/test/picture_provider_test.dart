// ignore_for_file: prefer_const_constructors

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
    SvgTheme? currentTheme;

    PictureInfoDecoder<T> decoderBuilder<T>(SvgTheme theme) {
      currentTheme = theme;
      return (T bytes, ColorFilter? colorFilter, String key) async =>
          MockPictureInfo();
    }

    group(
        'rebuilds the decoder using decoderBuilder '
        'when currentColor changes', () {
      test('NetworkPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final NetworkPicture networkPicture =
            NetworkPicture(decoderBuilder, 'url')
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = networkPicture.decoder;

        // Update the theme of PictureProvider to include currentColor.
        networkPicture.theme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
        );

        expect(networkPicture.decoder, isNotNull);
        expect(networkPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.currentColor, equals(color));
      });

      test('FilePicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final FilePicture filePicture = FilePicture(decoderBuilder, MockFile())
          ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = filePicture.decoder;

        // Update the theme of PictureProvider to include currentColor.
        filePicture.theme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
        );

        expect(filePicture.decoder, isNotNull);
        expect(filePicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.currentColor, equals(color));
      });

      test('MemoryPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final MemoryPicture memoryPicture =
            MemoryPicture(decoderBuilder, Uint8List(0))
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = memoryPicture.decoder;

        // Update the theme of PictureProvider to include currentColor.
        memoryPicture.theme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
        );

        expect(memoryPicture.decoder, isNotNull);
        expect(memoryPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.currentColor, equals(color));
      });

      test('StringPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final StringPicture stringPicture = StringPicture(decoderBuilder, '')
          ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<String>? decoder = stringPicture.decoder;

        // Update the theme of PictureProvider to include currentColor.
        stringPicture.theme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
        );

        expect(stringPicture.decoder, isNotNull);
        expect(stringPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.currentColor, equals(color));
      });

      test('ExactAssetPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final ExactAssetPicture exactAssetPicture =
            ExactAssetPicture(decoderBuilder, '')
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<String>? decoder = exactAssetPicture.decoder;

        // Update the theme of PictureProvider to include currentColor.
        exactAssetPicture.theme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
        );

        expect(exactAssetPicture.decoder, isNotNull);
        expect(exactAssetPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.currentColor, equals(color));
      });
    });

    group(
        'rebuilds the decoder using decoderBuilder '
        'when fontSize changes', () {
      test('NetworkPicture', () async {
        const double fontSize = 26.0;
        final NetworkPicture networkPicture =
            NetworkPicture(decoderBuilder, 'url');

        final PictureInfoDecoder<Uint8List>? decoder = networkPicture.decoder;

        // Update the theme of PictureProvider to include fontSize.
        networkPicture.theme = SvgTheme(
          fontSize: fontSize,
        );

        expect(networkPicture.decoder, isNotNull);
        expect(networkPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.fontSize, equals(fontSize));
      });

      test('FilePicture', () async {
        const double fontSize = 26.0;
        final FilePicture filePicture = FilePicture(decoderBuilder, MockFile());

        final PictureInfoDecoder<Uint8List>? decoder = filePicture.decoder;

        // Update the theme of PictureProvider to include fontSize.
        filePicture.theme = SvgTheme(
          fontSize: fontSize,
        );

        expect(filePicture.decoder, isNotNull);
        expect(filePicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.fontSize, equals(fontSize));
      });

      test('MemoryPicture', () async {
        const double fontSize = 26.0;
        final MemoryPicture memoryPicture =
            MemoryPicture(decoderBuilder, Uint8List(0));

        final PictureInfoDecoder<Uint8List>? decoder = memoryPicture.decoder;

        // Update the theme of PictureProvider to include fontSize.
        memoryPicture.theme = SvgTheme(
          fontSize: fontSize,
        );

        expect(memoryPicture.decoder, isNotNull);
        expect(memoryPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.fontSize, equals(fontSize));
      });

      test('StringPicture', () async {
        const double fontSize = 26.0;
        final StringPicture stringPicture = StringPicture(decoderBuilder, '');

        final PictureInfoDecoder<String>? decoder = stringPicture.decoder;

        // Update the theme of PictureProvider to include fontSize.
        stringPicture.theme = SvgTheme(
          fontSize: fontSize,
        );

        expect(stringPicture.decoder, isNotNull);
        expect(stringPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.fontSize, equals(fontSize));
      });

      test('ExactAssetPicture', () async {
        const double fontSize = 26.0;
        final ExactAssetPicture exactAssetPicture =
            ExactAssetPicture(decoderBuilder, '');

        final PictureInfoDecoder<String>? decoder = exactAssetPicture.decoder;

        // Update the theme of PictureProvider to include fontSize.
        exactAssetPicture.theme = SvgTheme(
          fontSize: fontSize,
        );

        expect(exactAssetPicture.decoder, isNotNull);
        expect(exactAssetPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme?.fontSize, equals(fontSize));
      });
    });

    test('Evicts from cache when theme changes', () async {
      expect(PictureProvider.cache.count, 0);
      const Color color = Color(0xFFB0E3BE);
      final StringPicture stringPicture = StringPicture(decoderBuilder, '');

      final PictureStream _ =
          stringPicture.resolve(createLocalPictureConfiguration(null));

      await null;
      expect(PictureProvider.cache.count, 1);

      stringPicture.theme = SvgTheme(currentColor: color);

      expect(PictureProvider.cache.count, 0);
    });
  });
}
