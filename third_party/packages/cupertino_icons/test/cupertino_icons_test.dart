// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This test file is primarily here to serve as a source for code excerpts.
library;

import 'dart:io' show File;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'icons_list.dart';

void main() async {
  testWidgets(
    'Cupertino Icon Test',
    (WidgetTester tester) async {
      // #docregion CupertinoIcon
      const Icon icon = Icon(
        CupertinoIcons.heart_fill,
        color: Colors.pink,
        size: 24.0,
      );
      // #enddocregion CupertinoIcon

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: icon,
          ),
        ),
      );

      expect(find.byType(Icon), findsOne);
    },
  );

  final String effectiveFontFamily = const TextStyle(fontFamily: CupertinoIcons.iconFont, package: CupertinoIcons.iconFontPackage).fontFamily!;
  final FontLoader fontLoader = FontLoader(effectiveFontFamily);
  final String filePath = path.canonicalize('assets/CupertinoIcons.ttf');
  final File file = File(filePath);
  fontLoader.addFont(file.readAsBytes().then((Uint8List v) => v.buffer.asByteData()));
  await fontLoader.load();

  group('Glyph Goldens', () {
    // The EM of the font is 512. Keep this a power of 2 for fixed-point arithmetic.
    const double iconSize = 128.0;
    const int iconsPerRow = 5;
    const int iconsPerCol = 5;
    const int iconsPerImage = iconsPerRow * iconsPerCol;
    const Size canvasSize = Size(iconSize * iconsPerRow, iconSize * iconsPerCol);
    const Widget fillerBox = SizedBox.square(dimension: iconSize);

    void registerTestForIconGroup(List<IconData> iconGroup) {
      assert(iconGroup.isNotEmpty);
      String hexCodePoint(int codePoint) => codePoint.toRadixString(16).toUpperCase().padLeft(4, '0');
      final int groupStartCodePoint = (iconGroup.first.codePoint ~/ iconsPerImage) * iconsPerImage;
      final String range = 'U+${hexCodePoint(groupStartCodePoint)}-${hexCodePoint(groupStartCodePoint + iconsPerImage - 1)}';

      testWidgets('font golden test: $range', (WidgetTester tester) async {
        addTearDown(tester.view.reset);
        tester.view.physicalSize = canvasSize * tester.view.devicePixelRatio;

        final List<Widget> children = List<Widget>.filled(iconsPerImage, fillerBox);
        for (final IconData icon in iconGroup) {
          children[icon.codePoint - groupStartCodePoint] = Icon(icon, size: iconSize);
        }

        final Widget widget = Center(
          child: SizedBox(
            height: iconSize * iconsPerCol,
            width: iconSize * iconsPerRow,
            child: RepaintBoundary(child: Wrap(children: children)),
          ),
        );
        await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: widget));
        await expectLater(find.byType(Wrap) , matchesGoldenFile('goldens/glyph_$range.png'));
      });
    }

    // Generating goldens for each glyph is very slow. Group the sorted icons
    // into codepoint-aligned groups (each of which has a max capacity of
    // iconsPerRow * iconsPerCol), so the goldens are easier to review when
    // codepoints are added or removed.
    int nextGroupStartIndex(int groupStartIndex) {
      int index = groupStartIndex;
      final int groupStartCodePoint = (icons[index].codePoint ~/ iconsPerImage) * iconsPerImage;
      final int groupEndCodePoint = groupStartCodePoint + iconsPerImage;
      while (index < icons.length) {
        if (icons[index].codePoint >= groupEndCodePoint) {
          return index;
        }
        index += 1;
      }
      assert(groupStartIndex <= index);
      assert(index <= groupStartIndex + iconsPerRow * iconsPerCol);
      return index;
    }

    int index = 0;
    while (index < icons.length) {
      final int nextIndex = nextGroupStartIndex(index);

      registerTestForIconGroup(icons.sublist(index, nextIndex));
      index = nextIndex;
    }
  });
}
