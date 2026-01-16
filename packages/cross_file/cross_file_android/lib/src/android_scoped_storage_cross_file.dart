// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'android_library.g.dart' as android;

/// Implementation of [PlatformScopedStorageXFile] for Android.
base class AndroidScopedStorageXFile extends PlatformScopedStorageXFile {
  /// Constructs an [AndroidScopedStorageXFile].
  AndroidScopedStorageXFile(super.params) : super.implementation();

  late final android.DocumentFile _documentFile =
      android.DocumentFile.fromSingleUri(singleUri: params.uri);

  late final android.ContentResolver _contentResolver =
      android.ContentResolver.instance;

  /// Maximum number of bytes to read at a time from the native Android
  /// InputStream.
  ///
  /// Only visible for testing.
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
    final int? fileLength = await length();
    if (fileLength == null) {
      throw UnsupportedError('Cannot access file length.');
    }

    int bytesToRead = (end ?? fileLength) - (start ?? 0);
    assert(bytesToRead >= 0);

    final android.InputStream? inputStream = await _contentResolver
        .openInputStream(params.uri);

    if (inputStream case final android.InputStream inputStream) {
      if (start != null && start > 0) {
        await inputStream.skip(start);
      }

      late android.InputStreamReadBytesResponse response;
      do {
        response = await inputStream.readBytes(
          min(bytesToRead, maxByteArrayLen),
        );
        yield response.bytes;
        bytesToRead -= response.returnValue;
      } while (response.returnValue > -1 && bytesToRead > 0);
    } else {
      throw NullInputStreamError(params.uri);
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final android.InputStream? inputStream = await _contentResolver
        .openInputStream(params.uri);
    if (inputStream case final android.InputStream inputStream) {
      return inputStream.readAllBytes();
    }

    throw NullInputStreamError(params.uri);
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
}

/// Error thrown when the native [android.InputStream] is not accessible.
class NullInputStreamError extends UnsupportedError {
  /// Constructs a [NullInputStreamError].
  NullInputStreamError(String uri)
    : super(
        'Failed to get native InputStream from file with path: $uri. '
        'App may not have permissions to access file.',
      );
}
