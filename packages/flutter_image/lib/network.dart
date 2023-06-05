// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Utilities for loading images from the network.
///
/// This library expands the capabilities of the basic [Image.network] and
/// [NetworkImage] provided by Flutter core libraries, to include a retry
/// mechanism and connectivity detection.
library network;

import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Fetches the image from the given URL, associating it with the given scale.
///
/// If [fetchStrategy] is specified, uses it instead of the
/// [defaultFetchStrategy] to obtain instructions for fetching the URL.
///
/// The image will be cached regardless of cache headers from the server.
@immutable
class NetworkImageWithRetry extends ImageProvider<NetworkImageWithRetry> {
  /// Creates an object that fetches the image at the given [url].
  const NetworkImageWithRetry(
    this.url, {
    this.scale = 1.0,
    this.fetchStrategy = defaultFetchStrategy,
    this.headers,
  });

  /// The HTTP client used to download images.
  static final io.HttpClient _client = io.HttpClient();

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The strategy used to fetch the [url] and retry when the fetch fails.
  ///
  /// This function is called at least once and may be called multiple times.
  /// The first time it is called, it is passed a null [FetchFailure], which
  /// indicates that this is the first attempt to fetch the [url]. Subsequent
  /// calls pass non-null [FetchFailure] values, which indicate that previous
  /// fetch attempts failed.
  final FetchStrategy fetchStrategy;

  /// HTTP Headers applied to the request.
  ///
  /// Keys from this map will be used as header field names and the
  /// values will be used as header values. A list of header names can
  /// be found at https://datatracker.ietf.org/doc/html/rfc7231#section-8.3
  ///
  /// If the value is a DateTime, an HTTP date format will be applied.
  /// If the value is an Iterable, each element will be added separately.
  /// For all other types the default Object.toString method will be used.
  ///
  /// Header names are converted to lower-case. If two header names are
  /// the same when converted to lower-case, they are considered to be
  /// the same header, with one set of values.
  ///
  /// For example, to add an authorization header to the request:
  ///
  /// final NetworkImageWithRetry subject = NetworkImageWithRetry(
  ///   Uri.parse('https://www.flutter.com/top_secret.png'),
  ///   headers: <String, Object>{
  ///     'Authorization': base64Encode(utf8.encode('user:password'))
  ///   },
  /// );
  final Map<String, Object>? headers;

  /// Used by [defaultFetchStrategy].
  ///
  /// This indirection is necessary because [defaultFetchStrategy] is used as
  /// the default constructor argument value, which requires that it be a const
  /// expression.
  static final FetchStrategy _defaultFetchStrategyFunction =
      const FetchStrategyBuilder().build();

  /// The [FetchStrategy] that [NetworkImageWithRetry] uses by default.
  static Future<FetchInstructions> defaultFetchStrategy(
      Uri uri, FetchFailure? failure) {
    return _defaultFetchStrategyFunction(uri, failure);
  }

  @override
  Future<NetworkImageWithRetry> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithRetry>(this);
  }

  @override
  // TODO(cyanglaz): migrate to use the new APIs
  // https://github.com/flutter/flutter/issues/105336
  // ignore: deprecated_member_use
  ImageStreamCompleter load(NetworkImageWithRetry key, DecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadWithRetry(key, decode),
        informationCollector: () sync* {
      yield ErrorDescription('Image provider: $this');
      yield ErrorDescription('Image key: $key');
    });
  }

  void _debugCheckInstructions(FetchInstructions? instructions) {
    assert(() {
      if (instructions == null) {
        if (fetchStrategy == defaultFetchStrategy) {
          throw StateError(
              'The default FetchStrategy returned null FetchInstructions. This\n'
              'is likely a bug in $runtimeType. Please file a bug at\n'
              'https://github.com/flutter/flutter/issues.');
        } else {
          throw StateError(
              'The custom FetchStrategy used to fetch $url returned null\n'
              'FetchInstructions. FetchInstructions must never be null, but\n'
              'instead instruct to either make another fetch attempt or give up.');
        }
      }
      return true;
    }());
  }

  Future<ImageInfo> _loadWithRetry(
      // TODO(cyanglaz): migrate to use the new APIs
      // https://github.com/flutter/flutter/issues/105336
      // ignore: deprecated_member_use
      NetworkImageWithRetry key,
      // ignore: deprecated_member_use
      DecoderCallback decode) async {
    assert(key == this);

    final Stopwatch stopwatch = Stopwatch()..start();
    final Uri resolved = Uri.base.resolve(key.url);
    FetchInstructions instructions = await fetchStrategy(resolved, null);
    _debugCheckInstructions(instructions);
    int attemptCount = 0;
    FetchFailure? lastFailure;

    while (!instructions.shouldGiveUp) {
      attemptCount += 1;
      io.HttpClientRequest? request;
      try {
        request = await _client
            .getUrl(instructions.uri)
            .timeout(instructions.timeout);

        headers?.forEach((String key, Object value) {
          request?.headers.add(key, value);
        });

        final io.HttpClientResponse response =
            await request.close().timeout(instructions.timeout);

        if (response.statusCode != 200) {
          throw FetchFailure._(
            totalDuration: stopwatch.elapsed,
            attemptCount: attemptCount,
            httpStatusCode: response.statusCode,
          );
        }

        final _Uint8ListBuilder builder = await response
            .fold(
              _Uint8ListBuilder(),
              (_Uint8ListBuilder buffer, List<int> bytes) => buffer..add(bytes),
            )
            .timeout(instructions.timeout);

        final Uint8List bytes = builder.data;

        if (bytes.lengthInBytes == 0) {
          throw FetchFailure._(
            totalDuration: stopwatch.elapsed,
            attemptCount: attemptCount,
            httpStatusCode: response.statusCode,
          );
        }

        final ui.Codec codec = await decode(bytes);
        final ui.Image image = (await codec.getNextFrame()).image;
        return ImageInfo(
          image: image,
          scale: key.scale,
        );
      } catch (error) {
        await request?.close();
        lastFailure = error is FetchFailure
            ? error
            : FetchFailure._(
                totalDuration: stopwatch.elapsed,
                attemptCount: attemptCount,
                originalException: error,
              );
        instructions = await fetchStrategy(instructions.uri, lastFailure);
        _debugCheckInstructions(instructions);
      }
    }

    if (instructions.alternativeImage != null) {
      return instructions.alternativeImage!;
    }

    assert(lastFailure != null);

    if (FlutterError.onError != null) {
      FlutterError.onError!(FlutterErrorDetails(
        exception: lastFailure!,
        library: 'package:flutter_image',
        context: ErrorDescription(
            '${objectRuntimeType(this, 'NetworkImageWithRetry')} failed to load ${instructions.uri}'),
      ));
    }

    throw lastFailure!;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NetworkImageWithRetry &&
        url == other.url &&
        scale == other.scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImageWithRetry')}("$url", scale: $scale)';
}

/// This function is called to get [FetchInstructions] to fetch an image.
///
/// The instructions are executed as soon as possible after the returned
/// [Future] resolves. If a delay in necessary between retries, use a delayed
/// [Future], such as [Future.delayed]. This is useful for implementing
/// back-off strategies and for recovering from lack of connectivity.
///
/// [uri] is the last requested image URI. A [FetchStrategy] may choose to use
/// a different URI (see [FetchInstructions.uri]).
///
/// If [failure] is `null`, then this is the first attempt to fetch the image.
///
/// If the [failure] is not `null`, it contains the information about the
/// previous attempt to fetch the image. A [FetchStrategy] may attempt to
/// recover from the failure by returning [FetchInstructions] that instruct
/// [NetworkImageWithRetry] to try again.
///
/// See [NetworkImageWithRetry.defaultFetchStrategy] for an example.
typedef FetchStrategy = Future<FetchInstructions> Function(
    Uri uri, FetchFailure? failure);

/// Instructions [NetworkImageWithRetry] uses to fetch the image.
@immutable
class FetchInstructions {
  /// Instructs [NetworkImageWithRetry] to give up trying to download the image.
  const FetchInstructions.giveUp({
    required this.uri,
    this.alternativeImage,
  })  : shouldGiveUp = true,
        timeout = Duration.zero;

  /// Instructs [NetworkImageWithRetry] to attempt to download the image from
  /// the given [uri] and [timeout] if it takes too long.
  const FetchInstructions.attempt({
    required this.uri,
    required this.timeout,
  })  : shouldGiveUp = false,
        alternativeImage = null;

  /// Instructs to give up trying.
  ///
  /// If [alternativeImage] is `null` reports the latest [FetchFailure] to
  /// [FlutterError].
  final bool shouldGiveUp;

  /// Timeout for the next network call.
  final Duration timeout;

  /// The URI to use on the next attempt.
  final Uri uri;

  /// Instructs to give up and use this image instead.
  final Future<ImageInfo>? alternativeImage;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'FetchInstructions')}(\n'
        '  shouldGiveUp: $shouldGiveUp\n'
        '  timeout: $timeout\n'
        '  uri: $uri\n'
        '  alternativeImage?: ${alternativeImage != null ? 'yes' : 'no'}\n'
        ')';
  }
}

/// Contains information about a failed attempt to fetch an image.
@immutable
class FetchFailure implements Exception {
  const FetchFailure._({
    required this.totalDuration,
    required this.attemptCount,
    this.httpStatusCode,
    this.originalException,
  }) : assert(attemptCount > 0);

  /// The total amount of time it has taken so far to download the image.
  final Duration totalDuration;

  /// The number of times [NetworkImageWithRetry] attempted to fetch the image
  /// so far.
  ///
  /// This value starts with 1 and grows by 1 with each attempt to fetch the
  /// image.
  final int attemptCount;

  /// HTTP status code, such as 500.
  final int? httpStatusCode;

  /// The exception that caused the fetch failure.
  final dynamic originalException;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'FetchFailure')}(\n'
        '  attemptCount: $attemptCount\n'
        '  httpStatusCode: $httpStatusCode\n'
        '  totalDuration: $totalDuration\n'
        '  originalException: $originalException\n'
        ')';
  }
}

/// An indefinitely growing builder of a [Uint8List].
class _Uint8ListBuilder {
  static const int _kInitialSize = 100000; // 100KB-ish

  int _usedLength = 0;
  Uint8List _buffer = Uint8List(_kInitialSize);

  Uint8List get data => Uint8List.view(_buffer.buffer, 0, _usedLength);

  void add(List<int> bytes) {
    _ensureCanAdd(bytes.length);
    _buffer.setAll(_usedLength, bytes);
    _usedLength += bytes.length;
  }

  void _ensureCanAdd(int byteCount) {
    final int totalSpaceNeeded = _usedLength + byteCount;

    int newLength = _buffer.length;
    while (totalSpaceNeeded > newLength) {
      newLength *= 2;
    }

    if (newLength != _buffer.length) {
      final Uint8List newBuffer = Uint8List(newLength);
      newBuffer.setAll(0, _buffer);
      newBuffer.setRange(0, _usedLength, _buffer);
      _buffer = newBuffer;
    }
  }
}

/// Determines whether the given HTTP [statusCode] is transient.
typedef TransientHttpStatusCodePredicate = bool Function(int statusCode);

/// Builds a [FetchStrategy] function that retries up to a certain amount of
/// times for up to a certain amount of time.
///
/// Pauses between retries with pauses growing exponentially (known as
/// exponential backoff). Each attempt is subject to a [timeout]. Retries only
/// those HTTP status codes considered transient by a
/// [transientHttpStatusCodePredicate] function.
class FetchStrategyBuilder {
  /// Creates a fetch strategy builder.
  ///
  /// All parameters must be non-null.
  const FetchStrategyBuilder({
    this.timeout = const Duration(seconds: 30),
    this.totalFetchTimeout = const Duration(minutes: 1),
    this.maxAttempts = 5,
    this.initialPauseBetweenRetries = const Duration(seconds: 1),
    this.exponentialBackoffMultiplier = 2,
    this.transientHttpStatusCodePredicate =
        defaultTransientHttpStatusCodePredicate,
  });

  /// A list of HTTP status codes that can generally be retried.
  ///
  /// You may want to use a different list depending on the needs of your
  /// application.
  static const List<int> defaultTransientHttpStatusCodes = <int>[
    0, // Network error
    408, // Request timeout
    500, // Internal server error
    502, // Bad gateway
    503, // Service unavailable
    504 // Gateway timeout
  ];

  /// Maximum amount of time a single fetch attempt is allowed to take.
  final Duration timeout;

  /// A strategy built by this builder will retry for up to this amount of time
  /// before giving up.
  final Duration totalFetchTimeout;

  /// Maximum number of attempts a strategy will make before giving up.
  final int maxAttempts;

  /// Initial amount of time between retries.
  final Duration initialPauseBetweenRetries;

  /// The pause between retries is multiplied by this number with each attempt,
  /// causing it to grow exponentially.
  final num exponentialBackoffMultiplier;

  /// A function that determines whether a given HTTP status code should be
  /// retried.
  final TransientHttpStatusCodePredicate transientHttpStatusCodePredicate;

  /// Uses [defaultTransientHttpStatusCodes] to determine if the [statusCode] is
  /// transient.
  static bool defaultTransientHttpStatusCodePredicate(int statusCode) {
    return defaultTransientHttpStatusCodes.contains(statusCode);
  }

  /// Builds a [FetchStrategy] that operates using the properties of this
  /// builder.
  FetchStrategy build() {
    return (Uri uri, FetchFailure? failure) async {
      if (failure == null) {
        // First attempt. Just load.
        return FetchInstructions.attempt(
          uri: uri,
          timeout: timeout,
        );
      }

      final bool isRetriableFailure = (failure.httpStatusCode != null &&
              transientHttpStatusCodePredicate(failure.httpStatusCode!)) ||
          failure.originalException is io.SocketException;

      // If cannot retry, give up.
      if (!isRetriableFailure || // retrying will not help
          failure.totalDuration > totalFetchTimeout || // taking too long
          failure.attemptCount > maxAttempts) {
        // too many attempts
        return FetchInstructions.giveUp(uri: uri);
      }

      // Exponential back-off.
      final Duration pauseBetweenRetries = initialPauseBetweenRetries *
          math.pow(exponentialBackoffMultiplier, failure.attemptCount - 1);
      await Future<void>.delayed(pauseBetweenRetries);

      // Retry.
      return FetchInstructions.attempt(
        uri: uri,
        timeout: timeout,
      );
    };
  }
}
