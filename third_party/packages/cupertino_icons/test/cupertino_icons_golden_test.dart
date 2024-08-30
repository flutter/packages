// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show File, Platform;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'icons_list.dart';

// The EM of the font is 512. Keep this a power of 2 for fixed-point arithmetic.
const double iconSize = 128.0;
const int iconsPerRow = 5;
const int iconsPerCol = 5;
const int iconsPerImage = iconsPerRow * iconsPerCol;

void main() async {
  // Do not run on web since this test uses dart:io.
  // The golden test runs on Linux only to avoid platform rendering differences.
  if (kIsWeb || !Platform.isLinux) {
    return;
  }
  final bool isMainChannel = !Platform.environment.containsKey('CHANNEL') ||
      Platform.environment['CHANNEL'] == 'main' ||
      Platform.environment['CHANNEL'] == 'master';
  // Only test against main to avoid rendering differences between flutter channels.
  if (!isMainChannel) {
    return;
  }
  // Load font.
  final String effectiveFontFamily = const TextStyle(
          fontFamily: CupertinoIcons.iconFont,
          package: CupertinoIcons.iconFontPackage)
      .fontFamily!;
  final FontLoader fontLoader = FontLoader(effectiveFontFamily);
  final String filePath = path.canonicalize('assets/CupertinoIcons.ttf');
  final File file = File(filePath);
  fontLoader
      .addFont(file.readAsBytes().then((Uint8List v) => v.buffer.asByteData()));
  await fontLoader.load();

  assert(icons.isNotEmpty);
  for (int index = 0; index < icons.length;) {
    final int groupEndCodePoint =
        (icons[index].codePoint ~/ iconsPerImage + 1) * iconsPerImage;
    final int next = icons.indexWhere(
        (IconData icon) => icon.codePoint >= groupEndCodePoint, index);
    final int nextIndex = next < 0 ? icons.length : next;
    registerTestForIconGroup(icons.slice(index, nextIndex));
    index = nextIndex;
  }
}

// Generating goldens for each glyph is very slow. Group the sorted icons
// into codepoint-aligned groups (each of which has a max capacity of
// iconsPerRow * iconsPerCol), so the goldens are easier to review when
// symbols are added or removed.
void registerTestForIconGroup(List<IconData> iconGroup) {
  assert(iconGroup.isNotEmpty);
  String hexCodePoint(int codePoint) =>
      codePoint.toRadixString(16).toUpperCase().padLeft(4, '0');
  final int groupStartCodePoint =
      (iconGroup.first.codePoint ~/ iconsPerImage) * iconsPerImage;
  final String range =
      'U+${hexCodePoint(groupStartCodePoint)}-${hexCodePoint(groupStartCodePoint + iconsPerImage - 1)}';

  testWidgets('font golden test: $range', (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    const Size canvasSize =
        Size(iconSize * iconsPerRow, iconSize * iconsPerCol);
    tester.view.physicalSize = canvasSize * tester.view.devicePixelRatio;

    const Widget fillerBox = SizedBox.square(dimension: iconSize);
    final List<Widget> children = List<Widget>.filled(iconsPerImage, fillerBox);
    for (final IconData icon in iconGroup) {
      children[icon.codePoint - groupStartCodePoint] =
          Icon(icon, size: iconSize);
    }

    final Widget widget = Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          height: iconSize * iconsPerCol,
          width: iconSize * iconsPerRow,
          child: RepaintBoundary(child: Wrap(children: children)),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    await expectLater(
        find.byType(Wrap), matchesGoldenFile('goldens/glyph_$range.png'));
  });
}
