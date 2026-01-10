// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cross_file_platform.dart';
import 'platform_cross_file_entity.dart';

/// Object specifying creation parameters for creating a [PlatformXFile].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformXFileCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformXFileCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidXFileCreationParams
///     extends PlatformXFileCreationParams {
///   AndroidXFileCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidXFileCreationParams.fromCreationParams(
///     PlatformXFileCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidXFileCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformXFileCreationParams
    extends PlatformXFileEntityCreationParams {
  /// Constructs a [PlatformXFileCreationParams].
  const PlatformXFileCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformXFile].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformXFile.extension].
///
/// ```dart
/// base class AndroidXFile extends PlatformXFile with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformXFileExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformXFileExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformXFileExtension implements PlatformXFileEntityExtension {}

/// Interface for a reference to a local data resource.
abstract base class PlatformXFile extends PlatformXFileEntity {
  /// Creates a new [PlatformXFile].
  factory PlatformXFile(PlatformXFileCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformXFile(params);
  }

  /// Used by the platform implementation to create a new [PlatformXFile].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformXFile.implementation(PlatformXFileCreationParams super.params);

  @override
  PlatformXFileCreationParams get params =>
      super.params as PlatformXFileCreationParams;

  /// Date and time when the resource was last modified, if the information is
  /// available.
  ///
  /// Platforms may throw an exception if the information is not available.
  Future<DateTime> lastModified();

  /// The length of the data represented by this uri, in bytes.
  ///
  /// Platforms may throw an exception if the information is not available.
  Future<int> length();

  /// Whether the resource represented by this reference can be read.
  Future<bool> canRead();

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
  Stream<Uint8List> openRead([int? start, int? end]);

  /// Reads the entire resource contents as a list of bytes.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<Uint8List> readAsBytes();

  /// Reads the entire resource contents as a string using the given Encoding.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<String> readAsString({Encoding encoding = utf8});

  /// The name of the resource represented by this object.
  ///
  /// The path is excluded from this value.
  Future<String?> name();
}
