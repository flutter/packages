// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, internal, protected;

import 'cross_entity.dart';

/// A reference to a local data resource.
@immutable
abstract base class XFile extends XEntity {
  /// Constructs a [XFile] from a specific platform implementation.
  @internal
  @protected
  const XFile(PlatformXFile super.platform);

  /// Implementation of [XFile] for the current platform.
  @internal
  @override
  PlatformXFile get platform => super.platform as PlatformXFile;

  /// Date and time when the resource was last modified, if the information is
  /// available.
  Future<DateTime?> lastModified() => platform.lastModified();

  /// The length of the data represented by this uri, in bytes.
  ///
  /// Returns null if the information is not available.
  Future<int?> length() => platform.length();

  /// Creates a new independent Stream for the contents of this resource.
  ///
  /// If start is present, the file will be read from byte-offset start.
  /// Otherwise from the beginning (index 0).
  ///
  /// If end is present, only bytes up to byte-index end will be read.
  /// Otherwise, until end of file.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    if (start != null && start < 0) {
      throw RangeError('`start` must be greater than 0. start: $start');
    } else if (end != null && end <= (start ?? 0)) {
      throw RangeError(
        '`end` must be greater than 0 and greater than `start`. start: $start, end: $end',
      );
    }

    yield* platform.openRead(start, end);
  }

  /// Reads the entire resource contents as a list of bytes.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<Uint8List> readAsBytes() => platform.readAsBytes();

  /// Reads the entire resource contents as a string using the given [Encoding].
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<String> readAsString({Encoding encoding = utf8}) =>
      platform.readAsString(encoding: encoding);

  /// The name of the resource represented by this object or null if the file
  /// doesn't exist or information is not available.
  ///
  /// If the file is identified by a path, only the base name of the file will
  /// be included in the name.
  Future<String?> name() => platform.name();
}
