// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses protobuf-generated code
library;

import 'package:test/test.dart';

import '../generator/fonts.pb.dart';
import '../generator/generator.dart';

void main() {
  group('Generator dedup of variable fonts', () {
    test('Removes variable font when static equivalent exists', () {
      // Simulate AR One Sans w400 normal: one static and one variable
      final staticFont = Font(
        file: FileSpec(hash: [1, 2, 3]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: false,
      );

      final variableFont = Font(
        file: FileSpec(hash: [4, 5, 6]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: true,
      );

      final fonts = [staticFont, variableFont];
      final List<Font> filteredVariants = deduplicateFonts(fonts);

      // Should have exactly 1 entry (the static one)
      expect(filteredVariants.length, 1);
      expect(filteredVariants[0].isVf, false);
      expect(filteredVariants[0].file.hash, [1, 2, 3]);
    });

    test('Keeps variable font when no static equivalent exists', () {
      final variableFont = Font(
        file: FileSpec(hash: [7, 8, 9]),
        weight: IntRange(start: 500, end: 500),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: true,
      );

      final fonts = [variableFont];
      final List<Font> filteredVariants = deduplicateFonts(fonts);

      // Should keep the variable font since no static exists
      expect(filteredVariants.length, 1);
      expect(filteredVariants[0].isVf, true);
      expect(filteredVariants[0].file.hash, [7, 8, 9]);
    });

    test('Handles mixed weights correctly', () {
      final static400 = Font(
        file: FileSpec(hash: [1]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: false,
      );

      final variable400 = Font(
        file: FileSpec(hash: [2]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: true,
      );

      final static700 = Font(
        file: FileSpec(hash: [3]),
        weight: IntRange(start: 700, end: 700),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: false,
      );

      final variable600 = Font(
        file: FileSpec(hash: [4]),
        weight: IntRange(start: 600, end: 600),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: true,
      );

      final fonts = [static400, variable400, static700, variable600];
      final List<Font> filteredVariants = deduplicateFonts(fonts);

      // Should have: static400, static700, variable600 (no static equivalent)
      // Should NOT have: variable400 (has static equivalent)
      expect(filteredVariants.length, 3);

      expect(
        filteredVariants.any((f) => f.file.hash[0] == 1),
        true,
      ); // static400
      expect(
        filteredVariants.any((f) => f.file.hash[0] == 2),
        false,
      ); // variable400 removed
      expect(
        filteredVariants.any((f) => f.file.hash[0] == 3),
        true,
      ); // static700
      expect(
        filteredVariants.any((f) => f.file.hash[0] == 4),
        true,
      ); // variable600 kept
    });

    test('Handles italic fonts correctly', () {
      final staticNormal = Font(
        file: FileSpec(hash: [1]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: false,
      );

      final variableNormal = Font(
        file: FileSpec(hash: [2]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 0.0, end: 0.0),
        isVf: true,
      );

      final staticItalic = Font(
        file: FileSpec(hash: [3]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 1.0, end: 1.0),
        isVf: false,
      );

      final variableItalic = Font(
        file: FileSpec(hash: [4]),
        weight: IntRange(start: 400, end: 400),
        italic: FloatRange(start: 1.0, end: 1.0),
        isVf: true,
      );

      final fonts = [
        staticNormal,
        variableNormal,
        staticItalic,
        variableItalic,
      ];
      final List<Font> filteredVariants = deduplicateFonts(fonts);

      // Should have only the two static fonts
      expect(filteredVariants.length, 2);
      expect(filteredVariants.every((f) => !f.isVf), true);
      expect(
        filteredVariants.any((f) => f.file.hash[0] == 1),
        true,
      ); // staticNormal
      expect(
        filteredVariants.any((f) => f.file.hash[0] == 3),
        true,
      ); // staticItalic
    });

    test('Preserves all static fonts regardless of variable duplicates', () {
      // Multiple static fonts of different weights, plus variable duplicates
      final statics = [
        Font(
          file: FileSpec(hash: [1]),
          weight: IntRange(start: 400, end: 400),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: false,
        ),
        Font(
          file: FileSpec(hash: [2]),
          weight: IntRange(start: 500, end: 500),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: false,
        ),
        Font(
          file: FileSpec(hash: [3]),
          weight: IntRange(start: 600, end: 600),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: false,
        ),
        Font(
          file: FileSpec(hash: [4]),
          weight: IntRange(start: 700, end: 700),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: false,
        ),
      ];

      final variables = [
        Font(
          file: FileSpec(hash: [11]),
          weight: IntRange(start: 400, end: 400),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: true,
        ),
        Font(
          file: FileSpec(hash: [12]),
          weight: IntRange(start: 500, end: 500),
          italic: FloatRange(start: 0.0, end: 0.0),
          isVf: true,
        ),
      ];

      final fonts = [...statics, ...variables];
      final List<Font> filteredVariants = deduplicateFonts(fonts);

      // Should have all 4 static fonts, variable fonts removed since they have static equivalents
      expect(filteredVariants.length, 4);
      expect(filteredVariants.every((f) => !f.isVf), true);
    });
  });
}
