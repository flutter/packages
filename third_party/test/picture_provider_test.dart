// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

// ignore: must_be_immutable
class FakePictureHandle extends Fake implements PictureHandle {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePictureInfo extends Fake implements PictureInfo {
  @override
  late CacheCompatibilityTester compatibilityTester;

  @override
  PictureHandle createHandle() {
    return FakePictureHandle();
  }
}

class FakeFile extends Fake implements File {}

void main() {
  group('PictureProvider', () {
    SvgTheme? currentTheme;
    late CacheCompatibilityTester compatibilityTester;

    PictureInfoDecoder<T> decoderBuilder<T>(SvgTheme theme) {
      currentTheme = theme;
      return (T bytes, ColorFilter? colorFilter, String key) async =>
          FakePictureInfo()..compatibilityTester = compatibilityTester;
    }

    setUp(() {
      compatibilityTester = const CacheCompatibilityTester();
    });

    group(
        'rebuilds the decoder using decoderBuilder '
        'when the theme changes', () {
      test('NetworkPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final NetworkPicture networkPicture =
            NetworkPicture(decoderBuilder, 'url')
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = networkPicture.decoder;

        const SvgTheme newTheme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
          xHeight: 6.5,
        );

        networkPicture.theme = newTheme;

        expect(networkPicture.decoder, isNotNull);
        expect(networkPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme, equals(newTheme));
      });

      test('FilePicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final FilePicture filePicture = FilePicture(decoderBuilder, FakeFile())
          ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = filePicture.decoder;

        const SvgTheme newTheme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
          xHeight: 6.5,
        );

        filePicture.theme = newTheme;

        expect(filePicture.decoder, isNotNull);
        expect(filePicture.decoder, isNot(equals(decoder)));
        expect(currentTheme, equals(newTheme));
      });

      test('MemoryPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final MemoryPicture memoryPicture =
            MemoryPicture(decoderBuilder, Uint8List(0))
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<Uint8List>? decoder = memoryPicture.decoder;

        const SvgTheme newTheme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
          xHeight: 6.5,
        );

        memoryPicture.theme = newTheme;

        expect(memoryPicture.decoder, isNotNull);
        expect(memoryPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme, equals(newTheme));
      });

      test('StringPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final StringPicture stringPicture = StringPicture(decoderBuilder, '')
          ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<String>? decoder = stringPicture.decoder;

        const SvgTheme newTheme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
          xHeight: 6.5,
        );

        stringPicture.theme = newTheme;

        expect(stringPicture.decoder, isNotNull);
        expect(stringPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme, equals(newTheme));
      });

      test('ExactAssetPicture', () async {
        const Color color = Color(0xFFB0E3BE);
        final ExactAssetPicture exactAssetPicture =
            ExactAssetPicture(decoderBuilder, '')
              ..theme = SvgTheme(fontSize: 14.0);

        final PictureInfoDecoder<String>? decoder = exactAssetPicture.decoder;

        const SvgTheme newTheme = SvgTheme(
          currentColor: color,
          fontSize: 14.0,
          xHeight: 6.5,
        );

        exactAssetPicture.theme = newTheme;

        expect(exactAssetPicture.decoder, isNotNull);
        expect(exactAssetPicture.decoder, isNot(equals(decoder)));
        expect(currentTheme, equals(newTheme));
      });
    });

    test('Evicts from cache when theme changes (incompatible)', () async {
      compatibilityTester = _TestCompabitibilityTester(false);
      expect(PictureProvider.cache.count, 0);
      const Color color = Color(0xFFB0E3BE);
      final StringPicture stringPicture = StringPicture(decoderBuilder, '');

      final PictureStream _ = stringPicture.resolve(
        createLocalPictureConfiguration(null),
      );

      await null;
      expect(PictureProvider.cache.count, 1);

      stringPicture.theme = SvgTheme(currentColor: color);

      expect(PictureProvider.cache.count, 0);
    });

    test('Does not evict from cache when theme changes (compatible)', () async {
      compatibilityTester = _TestCompabitibilityTester(true);
      expect(PictureProvider.cache.count, 0);
      const Color color = Color(0xFFB0E3BE);
      final StringPicture stringPicture = StringPicture(decoderBuilder, '');

      final PictureStream _ = stringPicture.resolve(
        createLocalPictureConfiguration(null),
      );

      await null;
      expect(PictureProvider.cache.count, 1);

      stringPicture.theme = SvgTheme(currentColor: color);

      expect(PictureProvider.cache.count, 1);
    });
  });
}

class _TestCompabitibilityTester extends CacheCompatibilityTester {
  _TestCompabitibilityTester(this.compatible);

  final bool compatible;
  @override
  bool isCompatible(Object oldData, Object newData) => compatible;
}
