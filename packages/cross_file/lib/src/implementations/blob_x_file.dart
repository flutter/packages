// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart';

import '../web_helpers/web_helpers.dart';
import '../x_file.dart';

/// A CrossFile that works on web, backed by a [Blob].
class BlobXFile implements XFile {
  /// Construct an [XFile] from a [Blob].
  ///
  /// `name` needs to be passed from the outside, since it's only available
  /// while handling [html.File]s (when the ObjectUrl is created).
  BlobXFile(
    Blob blob, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  })  : _browserBlob = blob,
        _mimeType = mimeType,
        _lastModified = lastModified ?? DateTime.fromMillisecondsSinceEpoch(0),
        _name = displayName;

  /// Creates a [XFile] from a web [File].
  factory BlobXFile.fromFile(File file) {
    return BlobXFile(
      file,
      mimeType: file.type,
      displayName: file.name,
      lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
    );
  }

  /// Construct an [XFile] from the [objectUrl] of a [Blob].
  ///
  /// Important: the Object URL of a blob must have been created by the same JS
  /// thread that is attempting to retrieve it. Otherwise, the blob will be null.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL_static
  static Future<BlobXFile> fromObjectURL(
    String objectUrl, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  }) async {
    return BlobXFile(
      await fetchBlob(objectUrl),
      mimeType: mimeType,
      displayName: displayName,
      lastModified: lastModified,
    );
  }

  final Blob _browserBlob;

  final String? _mimeType;
  final String? _name;
  final DateTime _lastModified;

  @override
  String? get mimeType => _mimeType;

  @override
  String? get name => _name;

  @override
  String? get path => null;

  @override
  Future<DateTime> lastModified() async => _lastModified;

  @override
  Future<Uint8List> readAsBytes() async {
    return blobToBytes(_browserBlob);
  }

  @override
  Future<int> length() async => _browserBlob.size;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }

  // TODO(dit): https://github.com/flutter/flutter/issues/91867 Implement openRead properly.
  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final Blob slice = _browserBlob.slice(
      start ?? 0,
      end ?? _browserBlob.size,
      _browserBlob.type,
    );
    yield await blobToBytes(slice);
  }

  /// Saves the data of this CrossFile at the location indicated by path.
  /// For the web implementation, the path variable is ignored.
  @override
  Future<void> saveTo(String path) async {
    // Save a Blob to file...
    await downloadBlob(_browserBlob, name ?? '');
  }
}
