// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

import 'web_helpers.dart';

/// Base implementation of [PlatformXFileCreationParams] for web.
@immutable
sealed class WebXFileCreationParams extends PlatformXFileCreationParams {
  /// Constructs a [WebXFileCreationParams].
  const WebXFileCreationParams({required super.uri, this.testOverrides});

  /// Overrides some functions to allow testing.
  @visibleForTesting
  final XFileTestOverrides? testOverrides;
}

/// Implementation of [WebXFileCreationParams] with an object url.
@immutable
base class UrlWebXFileCreationParams extends WebXFileCreationParams {
  /// Constructs a [UrlWebXFileCreationParams].
  const UrlWebXFileCreationParams({
    required String objectUrl,
    @visibleForTesting super.testOverrides,
  }) : super(uri: objectUrl);
}

/// Implementation of [WebXFileCreationParams] with a [Blob].
@immutable
base class BlobWebXFileCreationParams extends WebXFileCreationParams {
  /// Constructs a [BlobWebXFileCreationParams].
  BlobWebXFileCreationParams(
    this.blob, {
    this.autoRevokeObjectUrl = true,
    @visibleForTesting super.testOverrides,
  }) : super(uri: URL.createObjectURL(blob)) {
    if (autoRevokeObjectUrl) {
      _finalizer.attach(this, uri);
    }
  }

  static final Finalizer<String> _finalizer = Finalizer((String objectUrl) {
    URL.revokeObjectURL(objectUrl);
  });

  /// The raw data represented by a [WebXFile].
  final Blob blob;

  /// Whether the object url obtained from [blob] should be revoked when this
  /// instance is garbage collected.
  final bool autoRevokeObjectUrl;
}

/// Implementation of [PlatformXFile] for web.
base class WebXFile extends PlatformXFile with WebXFileExtension {
  /// Constructs a [WebXFile].
  WebXFile(super.params) : super.implementation();

  Blob? _cachedBlob;

  @override
  PlatformXFileExtension? get extension => this;

  @override
  late final WebXFileCreationParams params =
      super.params is WebXFileCreationParams
      ? super.params as WebXFileCreationParams
      : UrlWebXFileCreationParams(objectUrl: params.uri);

  @override
  Future<Blob> getBlob() async {
    return _cachedBlob ??= switch (params) {
      UrlWebXFileCreationParams() => await fetchBlob(params.uri),
      final BlobWebXFileCreationParams params => params.blob,
    };
  }

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async {
    try {
      await getBlob();
      return true;
    } catch (exception) {
      return false;
    }
  }

  @override
  Future<DateTime> lastModified() async {
    final Blob blob = await getBlob();
    if (blob is File) {
      return DateTime.fromMillisecondsSinceEpoch(blob.lastModified);
    }

    return DateTime.now();
  }

  @override
  Future<int> length() async {
    return (await getBlob()).size;
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final Blob blob = await getBlob();
    final Blob slice = blob.slice(start ?? 0, end ?? blob.size, blob.type);
    yield await blobToBytes(slice);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return blobToBytes(await getBlob());
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }

  @override
  Future<void> download([String? suggestedName]) async {
    final Blob blob = await getBlob();

    String? name;
    if (suggestedName != null) {
      name = suggestedName;
    } else if (blob is File) {
      name = blob.name;
    }

    downloadObjectUrl(params.uri, name, testOverrides: params.testOverrides);
  }

  @override
  Future<String?> name() async {
    final Blob blob = await getBlob();
    return blob is File ? blob.name : null;
  }
}

/// Provides platform specific features for [WebXFile].
mixin WebXFileExtension implements PlatformXFileExtension {
  /// The raw data represented by a [WebXFile].
  Future<Blob> getBlob();

  /// Attempts to download a [Blob], with [suggestedName] as the filename.
  Future<void> download([String? suggestedName]);
}
