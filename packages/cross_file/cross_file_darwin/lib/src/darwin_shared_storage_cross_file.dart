// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';

/// Implementation of [PlatformSharedStorageXFileCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinSharedStorageXFileCreationParams
    extends PlatformSharedStorageXFileCreationParams {
  /// Constructs a [DarwinSharedStorageXFileCreationParams].
  DarwinSharedStorageXFileCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformSharedStorageXFile] for iOS and macOS.
base class DarwinSharedStorageXFile extends PlatformSharedStorageXFile {
  /// Constructs a [DarwinSharedStorageXFile].
  DarwinSharedStorageXFile(super.params) : super.implementation();

  /// Maximum number of bytes to read at a time from the native Android
  /// InputStream.
  ///
  /// Only visible for testing.
  @visibleForTesting
  static const int maxByteArrayLen = 4 * 1024;

  @override
  late final DarwinSharedStorageXFileCreationParams params =
      super.params is DarwinSharedStorageXFileCreationParams
      ? super.params as DarwinSharedStorageXFileCreationParams
      : DarwinSharedStorageXFileCreationParams(uri: params.uri);

  Future<DarwinSharedStorageXFileCreationParams?> toBookmarkedFile() async {
    final String? bookmarkedUrl = await params.api.tryCreateBookmarkedUrl(
      params.uri,
    );

    return bookmarkedUrl != null
        ? DarwinSharedStorageXFileCreationParams(uri: bookmarkedUrl)
        : null;
    // final URL? url = await _originalUrl;
    // if (url case URL url) {
    //   final bool canRead = await url.startAccessingSecurityScopedResource();
    //   if (canRead) {
    //     try {
    //       final Uint8List? bookmarkData = await url.bookmarkData([], [], null);
    //       if (bookmarkData case Uint8List bookmarkData) {
    //         final URLResolvingBookmarkDataResponse response = await URL
    //             .resolvingBookmarkData(bookmarkData, [], null);
    //         if (response.isStale) {
    //           print('STALE');
    //           return null;
    //         }
    //         return response.url;
    //       }
    //     } finally {
    //       await url.stopAccessingSecurityScopedResource();
    //     }
    //   }
  }

  @override
  Future<bool> canRead() => params.api.isReadableFile(params.uri);

  @override
  Future<bool> exists() => params.api.fileExists(params.uri);

  @override
  Future<DateTime> lastModified() async {
    final int? lastModifiedSinceEpoch = await params.api.fileModificationDate(
      params.uri,
    );
    return lastModifiedSinceEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(lastModifiedSinceEpoch)
        : throw UnsupportedError('');
  }

  @override
  Future<int> length() async => await params.api.fileSize(params.uri) ?? 0;

  @override
  Future<String?> name() {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    int bytesToRead = (end ?? await length()) - (start ?? 0);
    assert(bytesToRead >= 0);

    final handle = FileHandle.forReadingFromUrl(url: params.uri);
    try {
      if (start != null && start > 0) {
        await handle.seek(start);
      }

      do {
        final Uint8List? bytes = await handle.readUpToCount(
          min(bytesToRead, maxByteArrayLen),
        );

        if (bytes == null) {
          throw StateError('Failed to read bytes from file: ${params.uri}');
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
    final handle = FileHandle.forReadingFromUrl(url: params.uri);
    try {
      final Uint8List? bytes = await handle.readToEnd();
      if (bytes == null) {
        throw StateError('Failed to read bytes from file: ${params.uri}');
      }

      return bytes;
    } finally {
      await handle.close();
    }
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return utf8.decodeStream(openRead());
  }

  // late final Future<URL?> _originalUrl = URL.fileURLWithPath(params.path);
  //
  // late final Future<URL?> _bookmarkUrl = () async {
  //   final URL? url = await _originalUrl;
  //   if (url case URL url) {
  //     final bool canRead = await url.startAccessingSecurityScopedResource();
  //     if (canRead) {
  //       try {
  //         final Uint8List? bookmarkData = await url.bookmarkData([], [], null);
  //         if (bookmarkData case Uint8List bookmarkData) {
  //           final URLResolvingBookmarkDataResponse response = await URL
  //               .resolvingBookmarkData(bookmarkData, [], null);
  //           if (response.isStale) {
  //             print('STALE');
  //             return null;
  //           }
  //           return response.url;
  //         }
  //       } finally {
  //         await url.stopAccessingSecurityScopedResource();
  //       }
  //     }
  //   }
  //
  //   return null;
  // }();
  //
  // @override
  // Future<bool> canRead() async {
  //   final URL? bookmarkUrl = await _bookmarkUrl;
  //   if (bookmarkUrl case URL bookmarkUrl) {
  //     return FileManager.defaultManager.isReadableFile(
  //       await bookmarkUrl.path(),
  //     );
  //   }
  //
  //   return false;
  // }
  //
  // @override
  // Future<bool> exists() async {
  //   final URL? bookmarkUrl = await _bookmarkUrl;
  //   if (bookmarkUrl case URL bookmarkUrl) {
  //     return FileManager.defaultManager.fileExists(await bookmarkUrl.path());
  //   }
  //
  //   return false;
  // }
  //
  // @override
  // Future<DateTime> lastModified() async {
  //   final URL? bookmarkUrl = await _bookmarkUrl;
  //   if (bookmarkUrl case URL bookmarkUrl) {
  //     final int? lastModifiedSinceEpoch = await FileManager.defaultManager
  //         .fileModificationDate(await bookmarkUrl.path());
  //     if (lastModifiedSinceEpoch case int lastModifiedSinceEpoch) {
  //       return DateTime.fromMillisecondsSinceEpoch(lastModifiedSinceEpoch);
  //     }
  //   }
  //
  //   throw UnsupportedError('cant read: ${params.path}');
  // }
  //
  // @override
  // Future<int> length() async {
  //   final URL? bookmarkUrl = await _bookmarkUrl;
  //   if (bookmarkUrl case URL bookmarkUrl) {
  //     final int? fileSize = await FileManager.defaultManager.fileSize(
  //       await bookmarkUrl.path(),
  //     );
  //     if (fileSize case int fileSize) {
  //       return fileSize;
  //     }
  //   }
  //
  //   throw UnsupportedError('cant read: ${params.path}');
  // }

  // @override
  // Stream<List<int>> openRead([int? start, int? end]) async* {
  //   if (await _bookmarkUrl case URL url) {
  //     final FileHandle fileHandle = FileHandle.forReadingFromUrl(url: url);
  //     try {
  //       Uint8List? bytes = await fileHandle.readUpToCount(4 * 1024);
  //       while (bytes != null && bytes.isNotEmpty) {
  //         yield bytes;
  //         // TODO: this is only supported on ios 13.4
  //         bytes = await fileHandle.readUpToCount(4 * 1024);
  //       }
  //     } finally {
  //       await fileHandle.close();
  //     }
  //   } else {
  //     throw UnsupportedError('Cant access bytes to file: ${params.path}');
  //   }
  // }
}
