// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'android_library.g.dart';

/// Implementation of [PlatformSharedStorageXFile] for Android.
base class AndroidSharedStorageXFile extends PlatformSharedStorageXFile {
  /// Constructs an [AndroidSharedStorageXFile].
  AndroidSharedStorageXFile(super.params) : super.implementation();

  late final DocumentFile _documentFile = DocumentFile.fromSingleUri(
    singleUri: params.uri,
  );

  late final ContentResolver _contentResolver = ContentResolver.instance;

  @override
  Future<DateTime> lastModified() async {
    return DateTime.fromMillisecondsSinceEpoch(
      await _documentFile.lastModified(),
    );
  }

  @override
  Future<int> length() => _documentFile.length();

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    int bytesToRead = (end ?? await length()) - (start ?? 0);
    assert(bytesToRead >= 0);

    final InputStream? inputStream = await _contentResolver.openInputStream(
      params.uri,
    );

    const int maxByteArrayLen = 4 * 1024;

    if (inputStream case final InputStream inputStream) {
      InputStreamReadBytesResponse response = await inputStream.readBytes(
        min(bytesToRead, maxByteArrayLen),
        start ?? 0,
      );
      bytesToRead -= response.returnValue;
      while (response.returnValue != -1 && bytesToRead > 0) {
        yield response.bytes;
        response = await inputStream.readBytes(
          min(bytesToRead, maxByteArrayLen),
          0,
        );
        bytesToRead -= response.returnValue;
      }
    } else {
      throw _createNullInputStreamError();
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final InputStream? inputStream = await _contentResolver.openInputStream(
      params.uri,
    );
    if (inputStream case final InputStream inputStream) {
      return inputStream.readAllBytes();
    }

    throw _createNullInputStreamError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return utf8.decode(await readAsBytes());
  }

  @override
  Future<bool> canRead() => _documentFile.canRead();

  @override
  Future<bool> exists() async {
    return await _documentFile.exists() && await _documentFile.isFile();
  }

  UnsupportedError _createNullInputStreamError() {
    return UnsupportedError(
      'Failed to get native InputStream from file with path: ${params.uri}. '
      'App may not have permissions to access file.',
    );
  }
}
