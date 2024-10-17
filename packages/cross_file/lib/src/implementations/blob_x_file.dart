// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart';

import '../web_helpers/web_helpers.dart';
import '../x_file.dart';

/// The metadata and shared behavior of a [blob]-backed [XFile].
abstract class BaseBlobXFile implements XFile {
  /// Store the metadata of the [blob]-backed [XFile].
  BaseBlobXFile({
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  })  : _mimeType = mimeType,
        _lastModified = lastModified ?? DateTime.fromMillisecondsSinceEpoch(0),
        _name = displayName;

  final String? _mimeType;
  final String? _name;
  final DateTime _lastModified;

  /// Asynchronously retrieve the [Blob] backing this [XFile].
  ///
  /// Subclasses must implement this getter. All the blob accesses on this file
  /// must be implemented off of it.
  Future<Blob> get blob;

  @override
  String? get mimeType => _mimeType;

  @override
  String get name => _name ?? '';

  @override
  String get path => '';

  @override
  Future<DateTime> lastModified() async => _lastModified;

  @override
  Future<Uint8List> readAsBytes() async {
    return blobToBytes(await blob);
  }

  @override
  Future<int> length() async => (await blob).size;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }

  // TODO(dit): https://github.com/flutter/flutter/issues/91867 Implement openRead properly.
  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final Blob browserBlob = await blob;
    final Blob slice = browserBlob.slice(
      start ?? 0,
      end ?? browserBlob.size,
      browserBlob.type,
    );
    yield await blobToBytes(slice);
  }
}

/// Construct an [XFile] backed by [blob].
///
/// `name` needs to be passed from the outside, since it's only available
/// while handling [html.File]s (when the ObjectUrl is created).
class BlobXFile extends BaseBlobXFile {
  /// Construct an [XFile] backed by [blob].
  ///
  /// `name` needs to be passed from the outside, since it's only available
  /// while handling [html.File]s (when the ObjectUrl is created).
  BlobXFile(
    Blob blob, {
    super.mimeType,
    super.displayName,
    super.lastModified,
  }) : _blob = blob;

  /// Creates a [XFile] from a web [File].
  factory BlobXFile.fromFile(File file) {
    return BlobXFile(
      file,
      mimeType: file.type,
      displayName: file.name,
      lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
    );
  }

  Blob _blob;

  // The Blob backing the file.
  @override
  Future<Blob> get blob async => _blob;

  /// Attempts to save the data of this [XFile], using the passed-in `blob`.
  ///
  /// The [path] variable is ignored.
  @override
  Future<void> saveTo(String path) async {
    // Save a Blob to file...
    await downloadBlob(_blob, name.isEmpty ? null : name);
  }
}

/// Constructs an [XFile] from the [objectUrl] of a [Blob].
///
/// Important: the Object URL of a blob must have been created by the same JS
/// thread that is attempting to retrieve it. Otherwise, the blob will not be
/// accessible.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL_static
class ObjectUrlBlobXFile extends BaseBlobXFile {
  /// Constructs an [XFile] from the [objectUrl] of a [Blob].
  ObjectUrlBlobXFile(
    String objectUrl, {
    super.mimeType,
    super.displayName,
    super.lastModified,
  }) : _objectUrl = objectUrl;

  final String _objectUrl;

  Blob? _cachedBlob;

  // The Blob backing the file.
  @override
  Future<Blob> get blob async => _cachedBlob ??= await fetchBlob(_objectUrl);

  /// Returns the [objectUrl] used to create this instance.
  @override
  String get path => _objectUrl;

  /// Attempts to save the data of this [XFile], using the passed-in `objectUrl`.
  ///
  /// The [path] variable is ignored.
  @override
  Future<void> saveTo(String path) async {
    downloadObjectUrl(_objectUrl, name.isEmpty ? null : name);
  }
}
