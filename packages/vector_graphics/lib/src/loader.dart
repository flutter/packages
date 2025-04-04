// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

/// An interface that can be implemented to support decoding vector graphic
/// binary assets from different byte sources.
///
/// A bytes loader class should not be constructed directly in a build method,
/// if this is done the corresponding [VectorGraphic] widget may repeatedly
/// reload the bytes.
///
/// Implementations must overide [toString] for debug reporting.
///
/// See also:
///   * [AssetBytesLoader], for loading from the asset bundle.
///   * [NetworkBytesLoader], for loading network bytes.
@immutable
abstract class BytesLoader {
  /// Const constructor to allow subtypes to be const.
  const BytesLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<ByteData> loadBytes(BuildContext? context);

  /// Create an object that can be used to uniquely identify this asset
  /// and loader combination.
  ///
  /// For most [BytesLoader] subclasses, this can safely return the same
  /// instance. If the loader looks up additional dependencies using the
  /// [context] argument of [loadBytes], then those objects should be
  /// incorporated into a new cache key.
  Object cacheKey(BuildContext? context) => this;
}

/// Loads vector graphics data from an asset bundle.
///
/// This loader does not cache bytes by default. The Flutter framework
/// implementations of [AssetBundle] also do not typically cache binary data.
///
/// Callers that would benefit from caching should provide a custom
/// [AssetBundle] that caches data, or should create their own implementation
/// of an asset bytes loader.
class AssetBytesLoader extends BytesLoader {
  /// A loader that retrieves bytes from an [AssetBundle].
  ///
  /// See [AssetBytesLoader].
  const AssetBytesLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
  });

  /// The name of the asset to load.
  final String assetName;

  /// The package name to load from, if any.
  final String? packageName;

  /// The asset bundle to use.
  ///
  /// If unspecified, [DefaultAssetBundle.of] the current context will be used.
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
  Future<ByteData> loadBytes(BuildContext? context) {
    return _resolveBundle(context).load(
      packageName == null ? assetName : 'packages/$packageName/$assetName',
    );
  }

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is AssetBytesLoader &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }

  @override
  Object cacheKey(BuildContext? context) {
    return _AssetByteLoaderCacheKey(
      assetName,
      packageName,
      _resolveBundle(context),
    );
  }

  @override
  String toString() =>
      'VectorGraphicAsset(${packageName != null ? '$packageName/' : ''}$assetName)';
}

// Replaces the cache key for [AssetBytesLoader] to account for the fact that
// different widgets may select a different asset bundle based on the return
// value of `DefaultAssetBundle.of(context)`.
@immutable
class _AssetByteLoaderCacheKey {
  const _AssetByteLoaderCacheKey(
      this.assetName, this.packageName, this.assetBundle);

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

/// A controller for loading vector graphics data from over the network.
///
/// This loader does not cache bytes requested from the network.
class NetworkBytesLoader extends BytesLoader {
  /// Creates a new loading context for network bytes.
  const NetworkBytesLoader(
    this.url, {
    this.headers,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  /// The HTTP headers to use for the network request.
  final Map<String, String>? headers;

  /// The [Uri] of the resource to request.
  final Uri url;

  final http.Client? _httpClient;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    final http.Client client = _httpClient ?? http.Client();
    final Uint8List bytes = (await client.get(url, headers: headers)).bodyBytes;
    return bytes.buffer.asByteData();
  }

  @override
  int get hashCode => Object.hash(url, headers);

  @override
  bool operator ==(Object other) {
    return other is NetworkBytesLoader &&
        other.headers == headers &&
        other.url == url;
  }

  @override
  String toString() => 'VectorGraphicNetwork($url)';
}
