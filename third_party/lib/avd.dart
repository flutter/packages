// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Picture;

import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import './svg.dart';
import 'src/avd/xml_parsers.dart';
import 'src/avd_parser.dart';
import 'src/picture_provider.dart';
import 'src/picture_stream.dart';
import 'src/vector_drawable.dart';

final Avd avd = Avd._();

class Avd {
  Avd._();

  Future<PictureInfo> avdPictureDecoder(
      Uint8List raw,
      bool allowDrawingOutsideOfViewBox,
      ColorFilter colorFilter,
      String key) async {
    final DrawableRoot avdRoot = await fromAvdBytes(raw, key);
    final Picture pic = avdRoot.toPicture(
        clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
        colorFilter: colorFilter);
    return PictureInfo(picture: pic, viewport: avdRoot.viewport.viewBoxRect);
  }

  Future<PictureInfo> avdPictureStringDecoder(
    String raw,
    bool allowDrawingOutsideOfViewBox,
    ColorFilter colorFilter,
    String key,
  ) async {
    final DrawableRoot avd = fromAvdString(raw, key);
    return PictureInfo(
      picture: avd.toPicture(
          clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
          colorFilter: colorFilter),
      viewport: avd.viewport.viewBoxRect,
      size: avd.viewport.size,
    );
  }

  Future<DrawableRoot> fromAvdBytes(Uint8List raw, String key) async {
    // TODO(dnfield): do utf decoding in another thread?
    // Might just have to live with potentially slow(ish) decoding, this is causing errors.
    // See: https://github.com/dart-lang/sdk/issues/31954
    // See: https://github.com/flutter/flutter/blob/bf3bd7667f07709d0b817ebfcb6972782cfef637/packages/flutter/lib/src/services/asset_bundle.dart#L66
    // if (raw.lengthInBytes < 20 * 1024) {
    return fromAvdString(utf8.decode(raw), key);
    // } else {
    //   final String str =
    //       await compute(_utf8Decode, raw, debugLabel: 'UTF8 decode for SVG');
    //   return fromSvgString(str);
    // }
  }

  // String _utf8Decode(Uint8List data) {
  //   return utf8.decode(data);
  // }

  /// Creates a [DrawableRoot] from a string of Android Vector Drawable data.
  DrawableRoot fromAvdString(String rawSvg, String key) {
    final XmlElement svg = xml.parse(rawSvg).rootElement;
    final DrawableViewport viewBox = parseViewBox(svg.attributes);
    final List<Drawable> children = svg.children
        .whereType<XmlElement>()
        .map((XmlElement child) => parseAvdElement(child, viewBox.viewBoxRect))
        .toList();
    // todo : style on root
    return DrawableRoot(viewBox, children, DrawableDefinitionServer(), null);
  }
}

/// Extends [VectorDrawableImage] to parse SVG data to [Drawable].
class AvdPicture extends SvgPicture {
  const AvdPicture(PictureProvider pictureProvider,
      {Key key,
      bool matchTextDirection = false,
      bool allowDrawingOutsideViewBox = false,
      WidgetBuilder placeholderBuilder})
      : super(pictureProvider,
            key: key,
            matchTextDirection: matchTextDirection,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            placeholderBuilder: placeholderBuilder);

  AvdPicture.string(String bytes,
      {bool matchTextDirection = false,
      bool allowDrawingOutsideViewBox = false,
      WidgetBuilder placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn,
      Key key})
      : this(
            StringPicture(
                allowDrawingOutsideViewBox == true
                    ? avdStringDecoderOutsideViewBox
                    : avdStringDecoder,
                bytes,
                colorFilter: _getColorFilter(color, colorBlendMode)),
            matchTextDirection: matchTextDirection,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            placeholderBuilder: placeholderBuilder,
            key: key);

  AvdPicture.asset(String assetName,
      {Key key,
      bool matchTextDirection = false,
      AssetBundle bundle,
      String package,
      bool allowDrawingOutsideViewBox = false,
      WidgetBuilder placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : this(
            ExactAssetPicture(
                allowDrawingOutsideViewBox == true
                    ? avdStringDecoderOutsideViewBox
                    : avdStringDecoder,
                assetName,
                bundle: bundle,
                package: package,
                colorFilter: _getColorFilter(color, colorBlendMode)),
            matchTextDirection: matchTextDirection,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            placeholderBuilder: placeholderBuilder,
            key: key);

  static ColorFilter _getColorFilter(Color color, BlendMode colorBlendMode) =>
      color == null
          ? null
          : ColorFilter.mode(color, colorBlendMode ?? BlendMode.srcIn);

  static final PictureInfoDecoder<Uint8List> avdByteDecoder =
      (Uint8List bytes, ColorFilter colorFilter, String key) =>
          avd.avdPictureDecoder(bytes, false, colorFilter, key);
  static final PictureInfoDecoder<String> avdStringDecoder =
      (String data, ColorFilter colorFilter, String key) =>
          avd.avdPictureStringDecoder(data, false, colorFilter, key);
  static final PictureInfoDecoder<Uint8List> avdByteDecoderOutsideViewBox =
      (Uint8List bytes, ColorFilter colorFilter, String key) =>
          avd.avdPictureDecoder(bytes, true, colorFilter, key);
  static final PictureInfoDecoder<String> avdStringDecoderOutsideViewBox =
      (String data, ColorFilter colorFilter, String key) =>
          avd.avdPictureStringDecoder(data, true, colorFilter, key);
}

/// Creates a [DrawableRoot] from a string of SVG data.
DrawableRoot fromAvdString(String rawSvg, Rect size) {
  final XmlElement svg = xml.parse(rawSvg).rootElement;
  final DrawableViewport viewBox = parseViewBox(svg.attributes);
  final List<Drawable> children = svg.children
      .whereType<XmlElement>()
      .map((XmlElement child) => parseAvdElement(child, size))
      .toList();
  // todo : style on root
  return DrawableRoot(viewBox, children, DrawableDefinitionServer(), null);
}
