// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui'
    show BlendMode, Color, ColorFilter, Locale, Rect, TextDirection, hashValues;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show BuildContext, DefaultAssetBundle, Directionality, Localizations;

import 'picture_cache.dart';
import 'picture_stream.dart';
import 'svg/theme.dart';
import 'utilities/file.dart';
import 'utilities/http.dart';

/// The signature of a function that can decode raw SVG data into a [Picture].
///
/// Used by [PictureProvider]. Several useful methods are provided in the [Svg]
/// class.
typedef PictureInfoDecoder<T> = Future<PictureInfo> Function(
  T data,
  ColorFilter? colorFilter,
  String key,
);

/// The signature of a builder that returns a [PictureInfoDecoder]
/// based on the provided [theme].
typedef PictureInfoDecoderBuilder<T> = PictureInfoDecoder<T> Function(
  SvgTheme theme,
);

/// Creates an [PictureConfiguration] based on the given [BuildContext] (and
/// optionally size).
///
/// This is the object that must be passed to [PictureProvider.resolve].
///
/// If this is not called from a build method, then it should be reinvoked
/// whenever the dependencies change, e.g. by calling it from
/// [State.didChangeDependencies], so that any changes in the environment are
/// picked up (e.g. if the device pixel ratio changes).
///
/// See also:
///
///  * [PictureProvider], which has an example showing how this might be used.
PictureConfiguration createLocalPictureConfiguration(
  BuildContext? context, {
  Rect? viewBox,
  ColorFilter? colorFilterOverride,
  Color? color,
  BlendMode? colorBlendMode,
}) {
  ColorFilter? filter = colorFilterOverride;
  if (filter == null && color != null) {
    filter = ColorFilter.mode(color, colorBlendMode ?? BlendMode.srcIn);
  }
  return PictureConfiguration(
    bundle: context != null ? DefaultAssetBundle.of(context) : rootBundle,
    locale: context != null ? Localizations.maybeLocaleOf(context) : null,
    textDirection: context != null ? Directionality.maybeOf(context) : null,
    viewBox: viewBox,
    platform: defaultTargetPlatform,
    colorFilter: filter,
  );
}

/// Configuration information passed to the [PictureProvider.resolve] method to
/// select a specific picture.
///
/// See also:
///
///  * [createLocalPictureConfiguration], which creates an [PictureConfiguration]
///    based on ambient configuration in a [Widget] environment.
///  * [PictureProvider], which uses [PictureConfiguration] objects to determine
///    which picture to obtain.
@immutable
class PictureConfiguration {
  /// Creates an object holding the configuration information for an [PictureProvider].
  ///
  /// All the arguments are optional. Configuration information is merely
  /// advisory and best-effort.
  const PictureConfiguration({
    this.bundle,
    this.locale,
    this.textDirection,
    this.viewBox,
    this.platform,
    this.colorFilter,
  });

  /// Creates an object holding the configuration information for an [PictureProvider].
  ///
  /// All the arguments are optional. Configuration information is merely
  /// advisory and best-effort.
  PictureConfiguration copyWith({
    AssetBundle? bundle,
    Locale? locale,
    TextDirection? textDirection,
    Rect? viewBox,
    TargetPlatform? platform,
    ColorFilter? colorFilter,
  }) {
    return PictureConfiguration(
      bundle: bundle ?? this.bundle,
      locale: locale ?? this.locale,
      textDirection: textDirection ?? this.textDirection,
      viewBox: viewBox ?? this.viewBox,
      platform: platform ?? this.platform,
      colorFilter: colorFilter ?? this.colorFilter,
    );
  }

  /// The preferred [AssetBundle] to use if the [PictureProvider] needs one and
  /// does not have one already selected.
  final AssetBundle? bundle;

  /// The language and region for which to select the picture.
  final Locale? locale;

  /// The reading direction of the language for which to select the picture.
  final TextDirection? textDirection;

  /// The size at which the picture will be rendered.
  final Rect? viewBox;

  /// The [TargetPlatform] for which assets should be used. This allows pictures
  /// to be specified in a platform-neutral fashion yet use different assets on
  /// different platforms, to match local conventions e.g. for color matching or
  /// shadows.
  final TargetPlatform? platform;

  /// The [ColorFilter], if any, that was applied to the drawing.
  final ColorFilter? colorFilter;

  /// a picture configuration that provides no additional information.
  ///
  /// Useful when resolving an [PictureProvider] without any context.
  static const PictureConfiguration empty = PictureConfiguration();

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PictureConfiguration &&
        other.bundle == bundle &&
        other.locale == locale &&
        other.textDirection == textDirection &&
        other.viewBox == viewBox &&
        other.platform == platform &&
        other.colorFilter == colorFilter;
  }

  @override
  int get hashCode =>
      hashValues(bundle, locale, viewBox, platform, colorFilter);

  @override
  String toString() {
    final StringBuffer result = StringBuffer();
    result.write('PictureConfiguration(');
    bool hasArguments = false;
    if (bundle != null) {
      result.write('bundle: $bundle');
      hasArguments = true;
    }
    if (locale != null) {
      if (hasArguments) {
        result.write(', ');
      }
      result.write('locale: $locale');
      hasArguments = true;
    }
    if (textDirection != null) {
      if (hasArguments) {
        result.write(', ');
      }
      result.write('textDirection: $textDirection');
      hasArguments = true;
    }
    if (viewBox != null) {
      if (hasArguments) {
        result.write(', ');
      }
      result.write('viewBox: $viewBox');
      hasArguments = true;
    }
    if (platform != null) {
      if (hasArguments) {
        result.write(', ');
      }
      result.write('platform: ${describeEnum(platform!)}');
      hasArguments = true;
    }
    if (colorFilter != null) {
      if (hasArguments) {
        result.write(', ');
      }
      result.write('colorFilter: $colorFilter');
      hasArguments = true;
    }
    result.write(')');
    return result.toString();
  }
}

/// Identifies a picture without committing to the precise final asset. This
/// allows a set of pictures to be identified and for the precise picture to later
/// be resolved based on the environment, e.g. the device pixel ratio.
///
/// To obtain an [PictureStream] from an [PictureProvider], call [resolve],
/// passing it an [PictureConfiguration] object.
///
/// [PictureProvider] uses the global [pictureCache] to cache pictures.
///
/// The type argument `T` is the type of the object used to represent a resolved
/// configuration. This is also the type used for the key in the picture cache. It
/// should be immutable and implement the [==] operator and the [hashCode]
/// getter. Subclasses should subclass a variant of [PictureProvider] with an
/// explicit `T` type argument.
///
/// The type argument does not have to be specified when using the type as an
/// argument (where any Picture provider is acceptable).
///
/// The following picture formats are supported: {@macro flutter.dart:ui.pictureFormats}
///
/// ## Sample code
///
/// The following shows the code required to write a widget that fully conforms
/// to the [PictureProvider] and [Widget] protocols. (It is essentially a
/// bare-bones version of the [widgets.Picture] widget.)
///
/// ```dart
/// class MyPicture extends StatefulWidget {
///   const MyPicture({
///     Key key,
///     @required this.PictureProvider,
///   }) : assert(PictureProvider != null),
///        super(key: key);
///
///   final PictureProvider PictureProvider;
///
///   @override
///   _MyPictureState createState() => _MyPictureState();
/// }
///
/// class _MyPictureState extends State<MyPicture> {
///   PictureStream _PictureStream;
///   PictureInfo _pictureInfo;
///
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     // We call _getPicture here because createLocalPictureConfiguration() needs to
///     // be called again if the dependencies changed, in case the changes relate
///     // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
///     _getPicture();
///   }
///
///   @override
///   void didUpdateWidget(MyPicture oldWidget) {
///     super.didUpdateWidget(oldWidget);
///     if (widget.PictureProvider != oldWidget.PictureProvider)
///       _getPicture();
///   }
///
///   void _getPicture() {
///     final PictureStream oldPictureStream = _PictureStream;
///     _PictureStream = widget.PictureProvider.resolve(createLocalPictureConfiguration(context));
///     if (_PictureStream.key != oldPictureStream?.key) {
///       // If the keys are the same, then we got the same picture back, and so we don't
///       // need to update the listeners. If the key changed, though, we must make sure
///       // to switch our listeners to the new picture stream.
///       oldPictureStream?.removeListener(_updatePicture);
///       _PictureStream.addListener(_updatePicture);
///     }
///   }
///
///   void _updatePicture(PictureInfo pictureInfo, bool synchronousCall) {
///     setState(() {
///       // Trigger a build whenever the picture changes.
///       _pictureInfo = pictureInfo;
///     });
///   }
///
///   @override
///   void dispose() {
///     _PictureStream.removeListener(_updatePicture);
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return RawPicture(
///       picture: _pictureInfo?.picture, // this is a dart:ui Picture object
///       scale: _pictureInfo?.scale ?? 1.0,
///     );
///   }
/// }
/// ```
@optionalTypeArgs
abstract class PictureProvider<T, U> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  PictureProvider(this.colorFilter, {required this.decoderBuilder})
      : _theme = const SvgTheme(),
        decoder = decoderBuilder(const SvgTheme());

  /// The decoder builder to build a [decoder] when [theme] changes.
  final PictureInfoDecoderBuilder<U> decoderBuilder;

  /// The [PictureInfoDecoder] to use for loading this picture.
  PictureInfoDecoder<U> decoder;

  /// The [PictureCache] for [Picture] objects created by [PictureProvider]
  /// implementations.
  static final PictureCache cache = PictureCache();

  /// The number of items in the [cache].
  @Deprecated('Use the `cache` object directly instead.')
  static int get cacheCount => cache.count;

  /// Clears the [cache].
  @Deprecated('Use the `cache` object directly instead.')
  static void clearCache() => cache.clear();

  /// The color filter to apply to the picture, if any.
  final ColorFilter? colorFilter;

  /// The default theme used when parsing SVG elements.
  SvgTheme get theme => _theme;
  SvgTheme _theme;

  /// Sets the [_theme] to [theme].
  ///
  /// A theme is used when parsing SVG elements. Changing the theme
  /// rebuilds a [decoder] using [decoderBuilder] and the new theme.
  /// This will make the decoded SVG picture use properties from
  /// the new theme.
  set theme(SvgTheme theme) {
    if (_theme == theme) {
      return;
    }
    decoder = decoderBuilder(theme);
    _theme = theme;
    if (_lastKey != null) {
      cache.evict(_lastKey!);
      _lastKey = null;
    }
  }

  T? _lastKey;

  /// Resolves this Picture provider using the given `configuration`, returning
  /// an [PictureStream].
  ///
  /// This is the public entry-point of the [PictureProvider] class hierarchy.
  ///
  /// Subclasses should implement [obtainKey] and [load], which are used by this
  /// method.
  PictureStream resolve(PictureConfiguration picture,
      {PictureErrorListener? onError}) {
    // ignore: unnecessary_null_comparison
    assert(picture != null);
    final PictureStream stream = PictureStream();
    obtainKey(picture).then<void>(
      (T key) {
        _lastKey = key;
        stream.setCompleter(
          cache.putIfAbsent(
            key!,
            () => load(key, onError: onError),
          ),
        );
      },
    ).catchError((Object exception, StackTrace stack) async {
      if (onError != null) {
        onError(exception, stack);
        return;
      }
      FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'SVG',
          context: ErrorDescription('while resolving a picture'),
          silent: true, // could be a network error or whatnot
          informationCollector: () sync* {
            yield DiagnosticsProperty<PictureProvider>(
                'Picture provider', this);
            yield DiagnosticsProperty<T>('Picture key', _lastKey,
                defaultValue: null);
          }));
    });
    return stream;
  }

  /// Converts a pictureProvider's settings plus a pictureConfiguration to a key
  /// that describes the precise picture to load.
  ///
  /// The type of the key is determined by the subclass. It is a value that
  /// unambiguously identifies the picture (_including its scale_) that the [load]
  /// method will fetch. Different [PictureProvider]s given the same constructor
  /// arguments and [PictureConfiguration] objects should return keys that are
  /// '==' to each other (possibly by using a class for the key that itself
  /// implements [==]).
  Future<T> obtainKey(PictureConfiguration picture);

  /// Converts a key into an [PictureStreamCompleter], and begins fetching the
  /// picture.
  @protected
  PictureStreamCompleter load(T key, {PictureErrorListener? onError});

  @override
  String toString() => '$runtimeType()';
}

/// An immutable key representing the current state of a [PictureProvider].
@immutable
class PictureKey<T> {
  /// Creates a new immutable key reprenseting the current state of a
  /// [PictureProvider] for the [PictureCache].
  const PictureKey(
    this.keyData, {
    required this.colorFilter,
    required this.theme,
  });

  /// Some unique identifier for the source of this picture, e.g. a file name or
  /// URL.
  ///
  /// If this is an iterable, it is assumed that the iterable will not be
  /// modified after creating this object.
  final T keyData;

  /// The color filter applied when this key was created.
  final ColorFilter? colorFilter;

  /// The theme used when this key was created.
  final SvgTheme theme;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PictureKey<T> &&
        keyData == other.keyData &&
        colorFilter == other.colorFilter &&
        theme == other.theme;
  }

  @override
  int get hashCode => hashValues(keyData.hashCode, colorFilter, theme);

  @override
  String toString() =>
      'PictureKey($keyData, colorFilter: $colorFilter, theme: $theme)';
}

/// Key for the picture obtained by an [AssetPicture] or [ExactAssetPicture].
///
/// This is used to identify the precise resource in the [pictureCache].
@immutable
class AssetBundlePictureKey extends PictureKey<String> {
  /// Creates the key for an [AssetPicture] or [AssetBundlePictureProvider].
  ///
  /// The arguments must not be null.
  const AssetBundlePictureKey({
    required this.bundle,
    required String name,
    ColorFilter? colorFilter,
    required SvgTheme theme,
  })  : assert(bundle != null), // ignore: unnecessary_null_comparison
        assert(name != null), // ignore: unnecessary_null_comparison
        super(name, colorFilter: colorFilter, theme: theme);

  /// The bundle from which the picture will be obtained.
  ///
  /// The picture is obtained by calling [AssetBundle.load] on the given [bundle]
  /// using the key given by [name].
  final AssetBundle bundle;

  /// The key to use to obtain the resource from the [bundle]. This is the
  /// argument passed to [AssetBundle.load].
  String get name => keyData;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AssetBundlePictureKey &&
        bundle == other.bundle &&
        name == other.name &&
        colorFilter == other.colorFilter &&
        theme == other.theme;
  }

  @override
  int get hashCode => hashValues(bundle, name, colorFilter, theme);

  @override
  String toString() =>
      '$runtimeType(bundle: $bundle, name: "$name", colorFilter: $colorFilter, theme: $theme)';
}

/// A subclass of [PictureProvider] that knows about [AssetBundle]s.
///
/// This factors out the common logic of [AssetBundle]-based [PictureProvider]
/// classes, simplifying what subclasses must implement to just [obtainKey].
abstract class AssetBundlePictureProvider
    extends PictureProvider<AssetBundlePictureKey, String> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  AssetBundlePictureProvider(PictureInfoDecoderBuilder<String> decoderBuilder,
      ColorFilter? colorFilter)
      : assert(decoderBuilder != null), // ignore: unnecessary_null_comparison
        super(colorFilter, decoderBuilder: decoderBuilder);

  /// Converts a key into an [PictureStreamCompleter], and begins fetching the
  /// picture using [_loadAsync].
  @override
  PictureStreamCompleter load(AssetBundlePictureKey key,
      {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError),
        informationCollector: () sync* {
      yield DiagnosticsProperty<PictureProvider>('Picture provider', this);
      yield DiagnosticsProperty<AssetBundlePictureKey>('Picture key', key);
    });
  }

  /// Fetches the picture from the asset bundle, decodes it, and returns a
  /// corresponding [PictureInfo] object.
  ///
  /// This function is used by [load].
  @protected
  Future<PictureInfo> _loadAsync(
      AssetBundlePictureKey key, PictureErrorListener? onError) async {
    final String data = await key.bundle.loadString(key.name);

    if (onError != null) {
      return decoder(
        data,
        key.colorFilter,
        key.toString(),
      ).catchError((Object error, StackTrace stack) {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
    }
    return decoder(data, key.colorFilter, key.toString());
  }
}

/// The [PictureKey.keyData] for a [NetworkPicture].
@immutable
class NetworkPictureKeyData {
  /// Creates [PictureKey.keyData] for a [NetworkPicture].
  const NetworkPictureKeyData({required this.url, required this.headers});

  /// The URL to request.
  final String url;

  /// The headers include in the GET request to [url].
  final Map<String, String>? headers;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NetworkPictureKeyData &&
        other.url == url &&
        other.headers == headers;
  }

  @override
  int get hashCode => hashValues(url, headers);
}

/// Fetches the given URL from the network, associating it with the given scale.
///
/// The picture will be cached regardless of cache headers from the server.
///
/// See also:
///
///  * [SvgPicture.network] for a shorthand of an [SvgPicture] widget backed by [NetworkPicture].
// TODO(ianh): Find some way to honour cache headers to the extent that when the
// last reference to a picture is released, we proactively evict the picture from
// our cache if the headers describe the picture as having expired at that point.
class NetworkPicture
    extends PictureProvider<PictureKey<NetworkPictureKeyData>, Uint8List> {
  /// Creates an object that fetches the picture at the given URL.
  ///
  /// The arguments must not be null.
  NetworkPicture(PictureInfoDecoderBuilder<Uint8List> decoderBuilder, this.url,
      {this.headers, ColorFilter? colorFilter})
      : assert(url != null), // ignore: unnecessary_null_comparison
        super(colorFilter, decoderBuilder: decoderBuilder);

  /// The URL from which the picture will be fetched.
  final String url;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch picture from network.
  final Map<String, String>? headers;

  @override
  Future<PictureKey<NetworkPictureKeyData>> obtainKey(
      PictureConfiguration picture) {
    return SynchronousFuture<PictureKey<NetworkPictureKeyData>>(
      PictureKey<NetworkPictureKeyData>(
        NetworkPictureKeyData(url: url, headers: headers),
        colorFilter: colorFilter,
        theme: theme,
      ),
    );
  }

  @override
  PictureStreamCompleter load(PictureKey<NetworkPictureKeyData> key,
      {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError),
        informationCollector: () sync* {
      yield DiagnosticsProperty<PictureProvider>('Picture provider', this);
      yield DiagnosticsProperty<PictureKey<NetworkPictureKeyData>>(
        'Picture key',
        key,
      );
    });
  }

  Future<PictureInfo> _loadAsync(PictureKey<NetworkPictureKeyData> key,
      {PictureErrorListener? onError}) async {
    assert(url == key.keyData.url);
    assert(headers == key.keyData.headers);
    final Uint8List bytes = await httpGet(url, headers: headers);

    if (onError != null) {
      return decoder(
        bytes,
        colorFilter,
        key.toString(),
      ).catchError((Object error, StackTrace stack) {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
    }
    return decoder(bytes, colorFilter, key.toString());
  }

  @override
  String toString() =>
      '$runtimeType("$url", headers: $headers, colorFilter: $colorFilter)';
}

/// Decodes the given [File] object as a picture, associating it with the given
/// scale.
///
/// See also:
///
///  * [SvgPicture.file] for a shorthand of an [SvgPicture] widget backed by [FilePicture].
class FilePicture extends PictureProvider<PictureKey<String>, Uint8List> {
  /// Creates an object that decodes a [File] as a picture.
  ///
  /// The arguments must not be null.
  FilePicture(PictureInfoDecoderBuilder<Uint8List> decoderBuilder, this.file,
      {ColorFilter? colorFilter})
      : assert(decoderBuilder != null), // ignore: unnecessary_null_comparison
        assert(file != null), // ignore: unnecessary_null_comparison
        super(colorFilter, decoderBuilder: decoderBuilder);

  /// The file to decode into a picture.
  final File file;

  @override
  Future<PictureKey<String>> obtainKey(PictureConfiguration picture) {
    return SynchronousFuture<PictureKey<String>>(
      PictureKey<String>(
        file.path,
        colorFilter: colorFilter,
        theme: theme,
      ),
    );
  }

  @override
  PictureStreamCompleter load(PictureKey<String> key,
      {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError),
        informationCollector: () sync* {
      yield DiagnosticsProperty<String>('Path', file.path);
    });
  }

  Future<PictureInfo?> _loadAsync(PictureKey<String> key,
      {PictureErrorListener? onError}) async {
    assert(key.keyData == file.path);

    final Uint8List data = await file.readAsBytes();
    if (data.isEmpty) {
      return null;
    }
    if (onError != null) {
      return decoder(
        data,
        colorFilter,
        key.toString(),
      ).catchError((Object error, StackTrace stack) async {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
    }
    return decoder(data, colorFilter, key.toString());
  }

  @override
  String toString() =>
      '$runtimeType("${file.path}", colorFilter: $colorFilter)';
}

/// Decodes the given [String] buffer as a picture, associating it with the
/// given scale.
///
/// The provided [bytes] buffer should not be changed after it is provided
/// to a [MemoryPicture]. To provide an [PictureStream] that represents a picture
/// that changes over time, consider creating a new subclass of [PictureProvider]
/// whose [load] method returns a subclass of [PictureStreamCompleter] that can
/// handle providing multiple pictures.
///
/// See also:
///
///  * [SvgPicture.memory] for a shorthand of an [SvgPicture] widget backed by [MemoryPicture].
class MemoryPicture extends PictureProvider<PictureKey<Uint8List>, Uint8List> {
  /// Creates an object that decodes a [Uint8List] buffer as a picture.
  ///
  /// The arguments must not be null.
  MemoryPicture(PictureInfoDecoderBuilder<Uint8List> decoderBuilder, this.bytes,
      {ColorFilter? colorFilter})
      : assert(bytes != null), // ignore: unnecessary_null_comparison
        super(colorFilter, decoderBuilder: decoderBuilder);

  /// The bytes to decode into a picture.
  final Uint8List bytes;

  @override
  Future<PictureKey<Uint8List>> obtainKey(PictureConfiguration picture) {
    return SynchronousFuture<PictureKey<Uint8List>>(
      PictureKey<Uint8List>(
        bytes,
        colorFilter: colorFilter,
        theme: theme,
      ),
    );
  }

  @override
  PictureStreamCompleter load(PictureKey<Uint8List> key,
      {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError));
  }

  Future<PictureInfo> _loadAsync(PictureKey<Uint8List> key,
      {PictureErrorListener? onError}) async {
    assert(key.keyData == bytes);
    if (onError != null) {
      return decoder(
        bytes,
        colorFilter,
        key.toString(),
      ).catchError((Object error, StackTrace stack) {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
    }
    return decoder(bytes, colorFilter, key.toString());
  }

  @override
  String toString() => '$runtimeType(${describeIdentity(bytes)})';
}

/// Decodes the given [String] as a picture, associating it with the
/// given scale.
///
/// The provided [String] should not be changed after it is provided
/// to a [StringPicture]. To provide an [PictureStream] that represents a picture
/// that changes over time, consider creating a new subclass of [PictureProvider]
/// whose [load] method returns a subclass of [PictureStreamCompleter] that can
/// handle providing multiple pictures.
///
/// See also:
///
///  * [SvgPicture.string] for a shorthand of an [SvgPicture] widget backed by [StringPicture].
class StringPicture extends PictureProvider<PictureKey<String>, String> {
  /// Creates an object that decodes a [Uint8List] buffer as a picture.
  ///
  /// The arguments must not be null.
  StringPicture(PictureInfoDecoderBuilder<String> decoderBuilder, this.string,
      {ColorFilter? colorFilter})
      : assert(string != null), // ignore: unnecessary_null_comparison
        super(colorFilter, decoderBuilder: decoderBuilder);

  /// The string to decode into a picture.
  final String string;

  @override
  Future<PictureKey<String>> obtainKey(PictureConfiguration picture) {
    return SynchronousFuture<PictureKey<String>>(
      PictureKey<String>(
        string,
        colorFilter: colorFilter,
        theme: theme,
      ),
    );
  }

  @override
  PictureStreamCompleter load(PictureKey<String> key,
      {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError));
  }

  Future<PictureInfo> _loadAsync(
    PictureKey<String> key, {
    PictureErrorListener? onError,
  }) {
    assert(key.keyData == string);
    if (onError != null) {
      return decoder(
        string,
        colorFilter,
        key.toString(),
      ).catchError((Object error, StackTrace stack) {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
    }
    return decoder(string, colorFilter, key.toString());
  }

  @override
  String toString() =>
      '$runtimeType(${describeIdentity(string)}, colorFilter: $colorFilter)';
}

/// Fetches a picture from an [AssetBundle], associating it with the given scale.
///
/// This implementation requires an explicit final [assetName] and [scale] on
/// construction, and ignores the device pixel ratio and size in the
/// configuration passed into [resolve]. For a resolution-aware variant that
/// uses the configuration to pick an appropriate picture based on the device
/// pixel ratio and size, see [AssetPicture].
///
/// ## Fetching assets
///
/// When fetching a picture provided by the app itself, use the [assetName]
/// argument to name the asset to choose. For instance, consider a directory
/// `icons` with a picture `heart.png`. First, the [pubspec.yaml] of the project
/// should specify its assets in the `flutter` section:
///
/// ```yaml
/// flutter:
///   assets:
///     - icons/heart.png
/// ```
///
/// Then, to fetch the picture and associate it with scale `1.5`, use
///
/// ```dart
/// AssetPicture('icons/heart.png', scale: 1.5)
/// ```
///
///## Assets in packages
///
/// To fetch an asset from a package, the [package] argument must be provided.
/// For instance, suppose the structure above is inside a package called
/// `my_icons`. Then to fetch the picture, use:
///
/// ```dart
/// AssetPicture('icons/heart.png', scale: 1.5, package: 'my_icons')
/// ```
///
/// Assets used by the package itself should also be fetched using the [package]
/// argument as above.
///
/// If the desired asset is specified in the `pubspec.yaml` of the package, it
/// is bundled automatically with the app. In particular, assets used by the
/// package itself must be specified in its `pubspec.yaml`.
///
/// A package can also choose to have assets in its 'lib/' folder that are not
/// specified in its `pubspec.yaml`. In this case for those pictures to be
/// bundled, the app has to specify which ones to include. For instance a
/// package named `fancy_backgrounds` could have:
///
/// ```
/// lib/backgrounds/background1.png
/// lib/backgrounds/background2.png
/// lib/backgrounds/background3.png
///```
///
/// To include, say the first picture, the `pubspec.yaml` of the app should specify
/// it in the `assets` section:
///
/// ```yaml
///  assets:
///    - packages/fancy_backgrounds/backgrounds/background1.png
/// ```
///
/// Note that the `lib/` is implied, so it should not be included in the asset
/// path.
///
/// See also:
///
///  * [SvgPicture.asset] for a shorthand of an [SvgPicture] widget backed by
///    [ExactAssetPicture] when using a scale.
class ExactAssetPicture extends AssetBundlePictureProvider {
  /// Creates an object that fetches the given picture from an asset bundle.
  ///
  /// The [assetName] and [scale] arguments must not be null. The [scale] arguments
  /// defaults to 1.0. The [bundle] argument may be null, in which case the
  /// bundle provided in the [PictureConfiguration] passed to the [resolve] call
  /// will be used instead.
  ///
  /// The [package] argument must be non-null when fetching an asset that is
  /// included in a package. See the documentation for the [ExactAssetPicture] class
  /// itself for details.
  ExactAssetPicture(
    PictureInfoDecoderBuilder<String> decoderBuilder,
    this.assetName, {
    this.bundle,
    this.package,
    ColorFilter? colorFilter,
  })  : assert(assetName != null), // ignore: unnecessary_null_comparison
        super(decoderBuilder, colorFilter);

  /// The name of the asset.
  final String assetName;

  /// The key to use to obtain the resource from the [bundle]. This is the
  /// argument passed to [AssetBundle.load].
  String get keyName =>
      package == null ? assetName : 'packages/$package/$assetName';

  /// The bundle from which the picture will be obtained.
  ///
  /// If the provided [bundle] is null, the bundle provided in the
  /// [PictureConfiguration] passed to the [resolve] call will be used instead. If
  /// that is also null, the [rootBundle] is used.
  ///
  /// The picture is obtained by calling [AssetBundle.load] on the given [bundle]
  /// using the key given by [keyName].
  final AssetBundle? bundle;

  /// The name of the package from which the picture is included. See the
  /// documentation for the [ExactAssetPicture] class itself for details.
  final String? package;

  @override
  Future<AssetBundlePictureKey> obtainKey(PictureConfiguration picture) {
    return SynchronousFuture<AssetBundlePictureKey>(
      AssetBundlePictureKey(
        bundle: bundle ?? picture.bundle ?? rootBundle,
        name: keyName,
        colorFilter: colorFilter,
        theme: theme,
      ),
    );
  }

  @override
  String toString() =>
      '$runtimeType(name: "$keyName", bundle: $bundle, colorFilter: $colorFilter)';
}
