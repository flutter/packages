// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';

/// Implementation of [PlatformScopedStorageXFileCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinScopedStorageXFileCreationParams
    extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [DarwinScopedStorageXFileCreationParams].
  DarwinScopedStorageXFileCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformScopedStorageXFile] for iOS and macOS.
base class DarwinScopedStorageXFile extends PlatformScopedStorageXFile {
  /// Constructs a [DarwinScopedStorageXFile].
  DarwinScopedStorageXFile(super.params) : super.implementation();

  /// Maximum number of bytes to read at a time from the native iOS
  /// `FileHandle`.
  ///
  /// Only visible for testing.
  @visibleForTesting
  static const int maxByteArrayLen = 4 * 1024;

  @override
  late final DarwinScopedStorageXFileCreationParams params =
      super.params is DarwinScopedStorageXFileCreationParams
      ? super.params as DarwinScopedStorageXFileCreationParams
      : DarwinScopedStorageXFileCreationParams(uri: super.params.uri);

  /// Attempt to create a bookmarked file that serves as a persistent reference
  /// to the file.
  Future<DarwinScopedStorageXFile?> toBookmarkedFile() async {
    final String? bookmarkedUrl = await params.api.tryCreateBookmarkedUrl(
      params.uri,
    );

    return bookmarkedUrl != null
        ? DarwinScopedStorageXFile(
            DarwinScopedStorageXFileCreationParams(uri: bookmarkedUrl),
          )
        : null;
  }

  @override
  Future<bool> canRead() => params.api.isReadableFile(params.uri);

  @override
  Future<bool> exists() => params.api.fileExists(params.uri);

  @override
  Future<DateTime?> lastModified() async {
    final int? lastModifiedSinceEpoch = await params.api.fileModificationDate(
      params.uri,
    );
    return lastModifiedSinceEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(lastModifiedSinceEpoch)
        : null;
  }

  @override
  Future<int?> length() => params.api.fileSize(params.uri);

  @override
  Future<String?> name() {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final int? fileLength = await length();
    if (fileLength == null) {
      throw UnsupportedError('Cannot access file length.');
    }

    int bytesToRead = (end ?? fileLength) - (start ?? 0);
    assert(bytesToRead >= 0);

    final FileHandle? handle = await FileHandle.forReadingFromUrl(params.uri);
    if (handle == null) {
      throw UnsupportedError('Cannot access file length.');
    }

    try {
      if (start != null && start > 0) {
        await handle.seek(start);
      }

      do {
        final Uint8List? bytes = await handle.readUpToCount(
          min(bytesToRead, maxByteArrayLen),
        );

        if (bytes == null) {
          throw UnsupportedError(
            'Failed to read bytes from file: ${params.uri}',
          );
        } else {
          yield bytes;
        }

        bytesToRead -= bytes.length;
      } while (bytesToRead > 0);
    } finally {
      await handle.close();
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final FileHandle? handle = await FileHandle.forReadingFromUrl(params.uri);
    if (handle == null) {
      throw UnsupportedError('Can not create file handle');
    }

    try {
      final Uint8List? bytes = await handle.readToEnd();
      if (bytes == null) {
        throw UnsupportedError('Failed to read bytes from file: ${params.uri}');
      }

      return bytes;
    } finally {
      await handle.close();
    }
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decodeStream(openRead());
  }
}
