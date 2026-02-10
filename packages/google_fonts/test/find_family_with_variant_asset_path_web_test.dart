// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/src/google_fonts_base.dart';
import 'package:google_fonts/src/google_fonts_family_with_variant.dart';
import 'package:google_fonts/src/google_fonts_variant.dart';

void main() {
  group('findFamilyWithVariantAssetPath', () {
    const familyWithVariant = GoogleFontsFamilyWithVariant(
      family: 'Roboto',
      googleFontsVariant: GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ),
    );

    group('common behavior', () {
      for (final isWeb in [true, false]) {
        test('returns null when manifestValues is null (web: $isWeb)', () {
          final String? result = findFamilyWithVariantAssetPath(
            familyWithVariant,
            null,
            isWeb: isWeb,
          );
          expect(result, isNull);
        });

        test('returns null when manifestValues is empty (web: $isWeb)', () {
          final String? result = findFamilyWithVariantAssetPath(
            familyWithVariant,
            <String>[],
            isWeb: isWeb,
          );
          expect(result, isNull);
        });

        test('returns null when font family does not match (web: $isWeb)', () {
          final String? result = findFamilyWithVariantAssetPath(
            familyWithVariant,
            <String>[
              'google_fonts/Lato-Regular.ttf',
              'google_fonts/OpenSans-Regular.ttf',
            ],
            isWeb: isWeb,
          );
          expect(result, isNull);
        });

        test('returns null when variant does not match (web: $isWeb)', () {
          final String? result = findFamilyWithVariantAssetPath(
            familyWithVariant,
            <String>[
              'google_fonts/Roboto-Bold.ttf',
              'google_fonts/Roboto-Italic.ttf',
            ],
            isWeb: isWeb,
          );
          expect(result, isNull);
        });

        test('matches correct variant with multiple fonts (web: $isWeb)', () {
          const boldItalicVariant = GoogleFontsFamilyWithVariant(
            family: 'Roboto',
            googleFontsVariant: GoogleFontsVariant(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          );
          final String? result =
              findFamilyWithVariantAssetPath(boldItalicVariant, <String>[
                'google_fonts/Roboto-Regular.ttf',
                'google_fonts/Roboto-Bold.ttf',
                'google_fonts/Roboto-BoldItalic.ttf',
                'google_fonts/Roboto-Italic.ttf',
              ], isWeb: isWeb);
          expect(result, equals('google_fonts/Roboto-BoldItalic.ttf'));
        });
      }
    });

    group('on web', () {
      test('supports woff2 format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.woff2'],
          isWeb: true,
        );
        expect(result, equals('google_fonts/Roboto-Regular.woff2'));
      });

      test('supports woff format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.woff'],
          isWeb: true,
        );
        expect(result, equals('google_fonts/Roboto-Regular.woff'));
      });

      test('supports ttf format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.ttf'],
          isWeb: true,
        );
        expect(result, equals('google_fonts/Roboto-Regular.ttf'));
      });

      test('supports otf format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.otf'],
          isWeb: true,
        );
        expect(result, equals('google_fonts/Roboto-Regular.otf'));
      });

      test('prefers woff2 over other formats regardless of manifest order', () {
        // Returns the highest priority file type regardless of the order in
        // which assets appear in the manifest.
        final String? result =
            findFamilyWithVariantAssetPath(familyWithVariant, <String>[
              'google_fonts/Roboto-Regular.ttf',
              'google_fonts/Roboto-Regular.woff2',
              'google_fonts/Roboto-Regular.woff',
            ], isWeb: true);
        expect(result, equals('google_fonts/Roboto-Regular.woff2'));
      });

      test('ignores unsupported file extensions', () {
        final String? result =
            findFamilyWithVariantAssetPath(familyWithVariant, <String>[
              'google_fonts/Roboto-Regular.eot',
              'google_fonts/Roboto-Regular.svg',
              'google_fonts/Roboto-Regular.woff2',
            ], isWeb: true);
        expect(result, equals('google_fonts/Roboto-Regular.woff2'));
      });
    });

    group('on non-web', () {
      test('supports ttf format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.ttf'],
          isWeb: false,
        );
        expect(result, equals('google_fonts/Roboto-Regular.ttf'));
      });

      test('supports otf format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>['google_fonts/Roboto-Regular.otf'],
          isWeb: false,
        );
        expect(result, equals('google_fonts/Roboto-Regular.otf'));
      });

      test('does not select woff2 format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>[
            'google_fonts/Roboto-Regular.woff2',
            'google_fonts/Roboto-Regular.ttf',
          ],
          isWeb: false,
        );
        expect(result, equals('google_fonts/Roboto-Regular.ttf'));
      });

      test('does not select woff format', () {
        final String? result = findFamilyWithVariantAssetPath(
          familyWithVariant,
          <String>[
            'google_fonts/Roboto-Regular.woff',
            'google_fonts/Roboto-Regular.otf',
          ],
          isWeb: false,
        );
        expect(result, equals('google_fonts/Roboto-Regular.otf'));
      });
    });
  });
}
