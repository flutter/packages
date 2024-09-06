// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'dart:convert';
import 'dart:typed_data';

/// The interface for a cross-platform "file", [XFile].
///
/// An `XFile` is a container that wraps a bunch of [bytes] with
/// some optional (platform-dependent) metadata, like a [path], [mimeType]
/// or [name].
///
/// Depending on the platform, the data can be backed by several different
/// storages, like a `File` from `dart:io`, or a `Blob` from `package:web`.
///
/// This class is a very limited subset of dart:io [File], so all
/// the methods should seem familiar.
///
/// Use the platform-specific factories to create `XFile`s with the most
/// appropriate backend for your platform. See the [XFileFactory] class
/// available for `web` and `native`.
abstract interface class XFile {
  @Deprecated('Use XFileFactory.fromPath from native/factory.dart.')
  factory XFile(
    String path, {
    String? mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  }) {
    throw UnimplementedError('Use XFileFactory.fromPath.');
  }

  @Deprecated('Use XFileFactory.fromBytes from native (or web)/factory.dart.')
  factory XFile.fromData(
    Uint8List bytes, {
    String? mimeType,
    String? name,
    int? length,
    DateTime? lastModified,
    String? path,
  }) {
    throw UnimplementedError('Use XFileFactory.fromBytes.');
  }

  /// Get the path of the picked file.
  ///
  /// **Not all `XFile` instances have a `path`.**
  ///
  /// This should only be used as a backwards-compatibility clutch
  /// for mobile apps, or cosmetic reasons only (to show the user
  /// the path they've picked).
  ///
  /// Accessing the data contained in the picked file by its path
  /// is platform-dependant (and won't work on web), so use the
  /// byte getters in the CrossFile instance instead.
  String? get path;

  /// The name of the file.
  ///
  /// **Not all `XFile` instances have a `name`.**
  ///
  /// The name can be inferred in the case where the XFile is backed by a
  /// `dart:io` or `package:web` `File` instance. In other cases, it can be
  /// passed when constructing the XFile object through the `displayName`
  /// property.
  ///
  /// Use only for cosmetic reasons, do not use this as a path.
  String? get name;

  /// The MIME-type of the file.
  ///
  /// **Not all `XFile` instances have a `mimeType`.**
  ///
  /// Only `File`-backed instances on the web have a MIME-type by default. In
  /// other implementations, the `mimeType` needs to be passed when constructing
  /// the XFile (if known).
  String? get mimeType;

  /// Asynchronously get the number of bytes (size) of this file.
  Future<int> length();

  /// Asynchronously read the entire file contents as a [String] using the given [encoding].
  ///
  /// By default, `encoding` is [utf8].
  ///
  /// Throws if the operation fails.
  Future<String> readAsString({Encoding encoding = utf8});

  /// Asynchronously read the entire file contents as a list of bytes.
  ///
  /// Throws if the operation fails.
  Future<Uint8List> readAsBytes();

  /// Create a new independent [Stream] for the contents of this file.
  ///
  /// If [start] is present, the file will be read from byte-offset `start`. Otherwise from the beginning (index 0).
  ///
  /// If [end] is present, only up to byte-index `end` will be read. Otherwise, until end of file.
  ///
  /// In order to make sure that system resources are freed, the stream must be read to completion or the subscription on the stream must be cancelled.
  Stream<Uint8List> openRead([int? start, int? end]);

  /// Asynchronously get the last-modified time for this file.
  Future<DateTime> lastModified();

  /// Save the `XFile` at the indicated [path].
  ///
  /// On the web platform, the [path] variable is ignored.
  Future<void> saveTo(String path);
}
