import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart' hide compute;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/src/utilities/http.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import '../svg.dart' show svg;
import 'utilities/compute.dart';
import 'utilities/file.dart';

/// A [BytesLoader] that parses a SVG data in an isolate and creates a
/// vector_graphics binary representation.
abstract class SvgLoader<T> extends BytesLoader {
  /// See class doc.
  const SvgLoader({
    this.theme = const SvgTheme(),
    this.colorMapper,
  });

  /// The theme to determine currentColor and font sizing attributes.
  final SvgTheme theme;

  /// The [ColorMapper] used to transform colors from the SVG, if any.
  final ColorMapper? colorMapper;

  /// Will be called in [compute] with the result of [prepareMessage].
  @protected
  String provideSvg(T? message);

  /// Will be called
  @protected
  Future<T?> prepareMessage(BuildContext? context) =>
      SynchronousFuture<T?>(null);

  Future<ByteData> _load(BuildContext? context) {
    return prepareMessage(context).then((T? message) {
      return compute((T? message) {
        return encodeSvg(
          xml: provideSvg(message),
          theme: theme,
          colorMapper: colorMapper,
          debugName: 'Svg loader',
          enableClippingOptimizer: false,
          enableMaskingOptimizer: false,
          enableOverdrawOptimizer: false,
        ).buffer.asByteData();
      }, message, debugLabel: 'Load Bytes');
    });
  }

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    return svg.cache.putIfAbsent(cacheKey(context), () => _load(context));
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
  int get hashCode => Object.hash(svg, theme, colorMapper);

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
  String provideSvg(void message) => utf8.decode(bytes);

  @override
  int get hashCode => Object.hash(svg, theme, colorMapper);

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
    return utf8.decode(bytes);
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
    return _resolveBundle(context).load(assetName);
  }

  @override
  String provideSvg(ByteData? message) =>
      utf8.decode(message!.buffer.asUint8List());

  @override
  Object cacheKey(BuildContext? context) {
    return _AssetByteLoaderCacheKey(
      assetName,
      packageName,
      _resolveBundle(context),
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
  });

  /// The [Uri] encoded resource address.
  final String url;

  /// Optional HTTP headers to send as part of the request.
  final Map<String, String>? headers;

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) {
    return httpGet(url, headers: headers);
  }

  @override
  String provideSvg(Uint8List? message) => utf8.decode(message!);

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
