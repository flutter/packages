import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart' hide compute;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vg;

import '../svg.dart' show svg;
import 'default_theme.dart';
import 'utilities/compute.dart';
import 'utilities/file.dart';

/// A theme used when decoding an SVG picture.
@immutable
class SvgTheme {
  /// Instantiates an SVG theme with the [currentColor]
  /// and [fontSize].
  ///
  /// Defaults the [fontSize] to 14.
  // WARNING WARNING WARNING
  // If this codebase ever decides to default the font size to something off the
  // BuildContext, caching logic will have to be updated. The font size can
  // temporarily and unexpectedly change during route transitions in common
  // patterns used in `MaterialApp`. This busts caching and destroys
  // performance.
  const SvgTheme({
    this.currentColor = const Color(0xFF000000),
    this.fontSize = 14,
    double? xHeight,
  }) : xHeight = xHeight ?? fontSize / 2;

  /// The default color applied to SVG elements that inherit the color property.
  /// See: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword
  final Color currentColor;

  /// The font size used when calculating em units of SVG elements.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units
  final double fontSize;

  /// The x-height (corpus size) of the font used when calculating ex units of SVG elements.
  /// Defaults to [fontSize] / 2 if not provided.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units, https://en.wikipedia.org/wiki/X-height
  final double xHeight;

  /// Creates a [vg.SvgTheme] from this.
  vg.SvgTheme toVgTheme() {
    return vg.SvgTheme(
      currentColor: vg.Color(currentColor.value),
      fontSize: fontSize,
      xHeight: xHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgTheme &&
        currentColor == other.currentColor &&
        fontSize == other.fontSize &&
        xHeight == other.xHeight;
  }

  @override
  int get hashCode => Object.hash(currentColor, fontSize, xHeight);

  @override
  String toString() =>
      'SvgTheme(currentColor: $currentColor, fontSize: $fontSize, xHeight: $xHeight)';
}

/// A class that transforms from one color to another during SVG parsing.
///
/// This object must be immutable so that it is suitable for use in the
/// [svg.cache].
@immutable
abstract class ColorMapper {
  /// Allows const constructors on subclasses.
  const ColorMapper();

  /// Returns a new color to use in place of [color] during SVG parsing.
  ///
  /// The SVG parser will call this method every time it parses a color
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  );
}

class _DelegateVgColorMapper extends vg.ColorMapper {
  _DelegateVgColorMapper(this.colorMapper);

  final ColorMapper colorMapper;

  @override
  vg.Color substitute(
      String? id, String elementName, String attributeName, vg.Color color) {
    final Color substituteColor = colorMapper.substitute(
        id, elementName, attributeName, Color(color.value));
    return vg.Color(substituteColor.value);
  }
}

/// A [BytesLoader] that parses a SVG data in an isolate and creates a
/// vector_graphics binary representation.
@immutable
abstract class SvgLoader<T> extends BytesLoader {
  /// See class doc.
  const SvgLoader({
    this.theme,
    this.colorMapper,
  });

  /// The theme to determine currentColor and font sizing attributes.
  final SvgTheme? theme;

  /// The [ColorMapper] used to transform colors from the SVG, if any.
  final ColorMapper? colorMapper;

  /// Will be called in [compute] with the result of [prepareMessage].
  @protected
  String provideSvg(T? message);

  /// Will be called
  @protected
  Future<T?> prepareMessage(BuildContext? context) =>
      SynchronousFuture<T?>(null);

  /// Returns the svg theme.
  @visibleForTesting
  @protected
  SvgTheme getTheme(BuildContext? context) {
    if (theme != null) {
      return theme!;
    }
    if (context != null) {
      final SvgTheme? defaultTheme = DefaultSvgTheme.of(context)?.theme;
      if (defaultTheme != null) {
        return defaultTheme;
      }
    }
    return const SvgTheme();
  }

  Future<ByteData> _load(BuildContext? context) {
    final SvgTheme theme = getTheme(context);
    return prepareMessage(context).then((T? message) {
      return compute((T? message) {
        return vg
            .encodeSvg(
              xml: provideSvg(message),
              theme: theme.toVgTheme(),
              colorMapper: colorMapper == null
                  ? null
                  : _DelegateVgColorMapper(colorMapper!),
              debugName: 'Svg loader',
              enableClippingOptimizer: false,
              enableMaskingOptimizer: false,
              enableOverdrawOptimizer: false,
            )
            .buffer
            .asByteData();
      }, message, debugLabel: 'Load Bytes');
    });
  }

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    return svg.cache.putIfAbsent(cacheKey(context), () => _load(context));
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final SvgTheme theme = getTheme(context);
    return SvgCacheKey(keyData: this, theme: theme, colorMapper: colorMapper);
  }
}

/// A [SvgTheme] aware cache key.
///
/// The theme must be part of the cache key to ensure that otherwise similar
/// SVGs get cached separately.
@immutable
class SvgCacheKey {
  /// See [SvgCacheKey].
  const SvgCacheKey({
    required this.keyData,
    required this.colorMapper,
    this.theme,
  });

  /// The theme for this cached SVG.
  final SvgTheme? theme;

  /// The other key data for the SVG.
  ///
  /// For most loaders, using the loader object itself is suitable.
  final Object keyData;

  /// The color mapper for the SVG, if any.
  final ColorMapper? colorMapper;

  @override
  int get hashCode => Object.hash(theme, keyData, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgCacheKey &&
        other.theme == theme &&
        other.keyData == keyData &&
        other.colorMapper == colorMapper;
  }
}

/// A [BytesLoader] that parses an SVG string in an isolate and creates a
/// vector_graphics binary representation.
class SvgStringLoader extends SvgLoader<void> {
  /// See class doc.
  const SvgStringLoader(
    this._svg, {
    super.theme,
    super.colorMapper,
  });

  final String _svg;

  @override
  String provideSvg(void message) {
    return _svg;
  }

  @override
  int get hashCode => Object.hash(_svg, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgStringLoader &&
        other._svg == _svg &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }
}

/// A [BytesLoader] that decodes and parses a UTF-8 encoded SVG string from a
/// [Uint8List] in an isolate and creates a vector_graphics binary
/// representation.
class SvgBytesLoader extends SvgLoader<void> {
  /// See class doc.
  const SvgBytesLoader(
    this.bytes, {
    super.theme,
    super.colorMapper,
  });

  /// The UTF-8 encoded XML bytes.
  final Uint8List bytes;

  @override
  String provideSvg(void message) => utf8.decode(bytes, allowMalformed: true);

  @override
  int get hashCode => Object.hash(bytes, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgBytesLoader &&
        other.bytes == bytes &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }
}

/// A [BytesLoader] that decodes SVG data from a file in an isolate and creates
/// a vector_graphics binary representation.
class SvgFileLoader extends SvgLoader<void> {
  /// See class doc.
  const SvgFileLoader(
    this.file, {
    super.theme,
    super.colorMapper,
  });

  /// The file containing the SVG data to decode and render.
  final File file;

  @override
  String provideSvg(void message) {
    final Uint8List bytes = file.readAsBytesSync();
    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  int get hashCode => Object.hash(file, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgFileLoader &&
        other.file == file &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }
}

// Replaces the cache key for [AssetBytesLoader] to account for the fact that
// different widgets may select a different asset bundle based on the return
// value of `DefaultAssetBundle.of(context)`.
@immutable
class _AssetByteLoaderCacheKey {
  const _AssetByteLoaderCacheKey(
    this.assetName,
    this.packageName,
    this.assetBundle,
  );

  final String assetName;
  final String? packageName;

  final AssetBundle assetBundle;

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is _AssetByteLoaderCacheKey &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }

  @override
  String toString() =>
      'VectorGraphicAsset(${packageName != null ? '$packageName/' : ''}$assetName)';
}

/// A [BytesLoader] that decodes and parses an SVG asset in an isolate and
/// creates a vector_graphics binary representation.
class SvgAssetLoader extends SvgLoader<ByteData> {
  /// See class doc.
  const SvgAssetLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
    super.theme,
    super.colorMapper,
  });

  /// The name of the asset, e.g. foo.svg.
  final String assetName;

  /// The package containing the asset.
  final String? packageName;

  /// The asset bundle to use, or [DefaultAssetBundle] if null.
  final AssetBundle? assetBundle;

  AssetBundle _resolveBundle(BuildContext? context) {
    if (assetBundle != null) {
      return assetBundle!;
    }
    if (context != null) {
      return DefaultAssetBundle.of(context);
    }
    return rootBundle;
  }

  @override
  Future<ByteData?> prepareMessage(BuildContext? context) {
    return _resolveBundle(context).load(
      packageName == null ? assetName : 'packages/$packageName/$assetName',
    );
  }

  @override
  String provideSvg(ByteData? message) =>
      utf8.decode(message!.buffer.asUint8List(), allowMalformed: true);

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final SvgTheme theme = getTheme(context);
    return SvgCacheKey(
      theme: theme,
      colorMapper: colorMapper,
      keyData: _AssetByteLoaderCacheKey(
        assetName,
        packageName,
        _resolveBundle(context),
      ),
    );
  }

  @override
  int get hashCode =>
      Object.hash(assetName, packageName, assetBundle, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgAssetLoader &&
        other.assetName == assetName &&
        other.packageName == packageName &&
        other.assetBundle == assetBundle &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }

  @override
  String toString() => 'SvgAssetLoader($assetName)';
}

/// A [BytesLoader] that decodes and parses a UTF-8 encoded SVG string the
/// network in an isolate and creates a vector_graphics binary representation.
class SvgNetworkLoader extends SvgLoader<Uint8List> {
  /// See class doc.
  const SvgNetworkLoader(
    this.url, {
    this.headers,
    super.theme,
    super.colorMapper,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  /// The [Uri] encoded resource address.
  final String url;

  /// Optional HTTP headers to send as part of the request.
  final Map<String, String>? headers;

  final http.Client? _httpClient;

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    final http.Client client = _httpClient ?? http.Client();
    final http.Response response =
        await client.get(Uri.parse(url), headers: headers);
    if (_httpClient == null) {
      client.close();
    }
    return response.bodyBytes;
  }

  @override
  String provideSvg(Uint8List? message) =>
      utf8.decode(message!, allowMalformed: true);

  @override
  int get hashCode => Object.hash(url, headers, theme, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgNetworkLoader &&
        other.url == url &&
        other.headers == headers &&
        other.theme == theme &&
        other.colorMapper == colorMapper;
  }

  @override
  String toString() => 'SvgNetworkLoader($url)';
}
