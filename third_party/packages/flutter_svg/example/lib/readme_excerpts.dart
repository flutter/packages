// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// #docregion OutputConversion
import 'dart:ui' as ui;

// #enddocregion OutputConversion

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// #docregion PrecompiledAsset
import 'package:vector_graphics/vector_graphics.dart';
// #enddocregion PrecompiledAsset

/// Loads an SVG asset.
Widget loadAsset() {
  // #docregion SimpleAsset
  const String assetName = 'assets/dart.svg';
  final Widget svg = SvgPicture.asset(
    assetName,
    semanticsLabel: 'Dart Logo',
  );
  // #enddocregion SimpleAsset
  return svg;
}

/// Loads an SVG asset.
Widget loadColorizedAsset() {
  // #docregion ColorizedAsset
  const String assetName = 'assets/simple/dash_path.svg';
  final Widget svgIcon = SvgPicture.asset(
    assetName,
    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
    semanticsLabel: 'Red dash paths',
  );
  // #enddocregion ColorizedAsset
  return svgIcon;
}

/// Demonstrates loading an asset that doesn't exist.
Widget loadMissingAsset() {
  // #docregion MissingAsset
  // Will print error messages to the console.
  const String assetName = 'assets/image_that_does_not_exist.svg';
  final Widget svg = SvgPicture.asset(
    assetName,
  );
  // #enddocregion MissingAsset
  return svg;
}

/// Demonstrates loading an asset with a placeholder.
// This method should *not* be called in tests, as tests should not be
// attempting to load from random uncontrolled locations. Using a real URL,
// such as a GitHub URL pointing to this package's assets, would make the
// README example harder to understand.
Widget loadNetworkAssetWithPlaceholder() {
  // #docregion AssetWithPlaceholder
  final Widget networkSvg = SvgPicture.network(
    'https://site-that-takes-a-while.com/image.svg',
    semanticsLabel: 'A shark?!',
    placeholderBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: const CircularProgressIndicator()),
  );
  // #enddocregion AssetWithPlaceholder
  return networkSvg;
}

/// Demonstrates loading a precompiled asset.
// This asset doesn't exist in the example app, but this code can still be run
// to sanity-check the structure of the example code.
Widget loadPrecompiledAsset() {
  // #docregion PrecompiledAsset
  const Widget svg = SvgPicture(AssetBytesLoader('assets/foo.svg.vec'));
  // #enddocregion PrecompiledAsset
  return svg;
}

/// Demonstrates converting SVG to another type.
Future<ui.Image> convertSvgOutput() async {
  final Canvas canvas = Canvas(ui.PictureRecorder());
  const int width = 100;
  const int height = 100;

  // #docregion OutputConversion
  const String rawSvg = '''<svg ...>...</svg>''';
  final PictureInfo pictureInfo =
      await vg.loadPicture(const SvgStringLoader(rawSvg), null);

  // You can draw the picture to a canvas:
  canvas.drawPicture(pictureInfo.picture);

  // Or convert the picture to an image:
  final ui.Image image = await pictureInfo.picture.toImage(width, height);

  pictureInfo.picture.dispose();
  // #enddocregion OutputConversion
  return image;
}

// #docregion ColorMapper
class _MyColorMapper extends ColorMapper {
  const _MyColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFFFF0000)) {
      return Colors.blue;
    }
    if (color == const Color(0xFF00FF00)) {
      return Colors.yellow;
    }
    return color;
  }
}
// #enddocregion ColorMapper

/// Demonstrates loading an SVG asset with a color mapping.
Widget loadWithColorMapper() {
  // #docregion ColorMapper
  const String svgString = '''
<svg viewBox="0 0 100 100">
  <rect width="50" height="50" fill="#FF0000" />
  <circle cx="75" cy="75" r="25" fill="#00FF00" />
</svg>
''';
  final Widget svgIcon = SvgPicture.string(
    svgString,
    colorMapper: const _MyColorMapper(),
  );
  // #enddocregion ColorMapper
  return svgIcon;
}
