// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'android_library.g.dart' as android;

/// Implementation of [PlatformScopedStorageXFile] for Android.
base class AndroidScopedStorageXFile extends PlatformScopedStorageXFile {
  /// Constructs an [AndroidScopedStorageXFile].
  AndroidScopedStorageXFile(super.params) : super.implementation();

  late final android.DocumentFile _documentFile = android.DocumentFile.fromSingleUri(
    singleUri: params.uri,
  );

  late final android.ContentResolver _contentResolver = android.ContentResolver.instance;

  /// Maximum number of bytes to read at a time from the native Android
  /// InputStream.
  ///
  /// Only visible for testing.
  ///
  /// This can be set to any arbitrary size, but 4KB was chosen because it seems
  /// like a good size that balances between minimizing disk size use and
  /// minimizing I/O operations.
  @visibleForTesting
  static const int maxByteArrayLen = 4 * 1024;

  @override
  Future<DateTime?> lastModified() async {
    final int msSinceEpoch = await _documentFile.lastModified();
    if (msSinceEpoch == 0) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
  }

  @override
  Future<int?> length() async {
    final int length = await _documentFile.length();
    if (length == 0) {
      return null;
    }

    return length;
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    if (start != null && start < 0) {
      throw RangeError('`start` must be greater than 0. start: $start');
    } else if (end != null && end <= (start ?? 0)) {
      throw RangeError(
        '`end` must be greater than 0 and greater than `start`. start: $start, end: $end',
      );
    }

    final android.InputStream? inputStream = await _contentResolver.openInputStream(params.uri);
    if (inputStream case final android.InputStream inputStream) {
      int currentByteIndex = start ?? 0;

      if (currentByteIndex > 0) {
        await inputStream.skip(currentByteIndex);
      }

      Uint8List chunk = await inputStream.readBytes(maxByteArrayLen);
      while (chunk.isNotEmpty && (end == null || currentByteIndex < end)) {
        if (end == null) {
          yield chunk;
        } else {
          yield Uint8List.sublistView(chunk, 0, end - currentByteIndex);
        }
        currentByteIndex += chunk.length;

        chunk = await inputStream.readBytes(maxByteArrayLen);
      }
    } else {
      throw NullInputStreamException(params.uri);
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final android.InputStream? inputStream = await _contentResolver.openInputStream(params.uri);
    if (inputStream case final android.InputStream inputStream) {
      return inputStream.readAllBytes();
    }

    throw NullInputStreamException(params.uri);
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decodeStream(openRead());
  }

  @override
  Future<bool> canRead() => _documentFile.canRead();

  @override
  Future<bool> exists() async {
    return await _documentFile.exists() && await _documentFile.isFile();
  }

  @override
  Future<String?> name() => _documentFile.getName();

  @override
  Future<void> dispose() async {
    // Reference to the resource does not need to be released.
  }
}

/// Error thrown when the native [android.InputStream] is not accessible.
final class NullInputStreamException implements Exception {
  /// Constructs a [NullInputStreamException].
  NullInputStreamException(this.uri);

  /// The URI the input stream that was request for.
  final String uri;

  @override
  String toString() {
    return 'NullInputStreamException: Failed to get native InputStream from file with path: $uri. '
        'App may not have permissions to access file.';
  }
}
