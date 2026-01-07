// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:meta/meta.dart';

import 'cross_file_entity.dart';

/// A reference to a local data resource.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.XFile.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the dart:io implementation of `cross_file`:
///
/// ```dart
/// final XFile file = XFile('my/file.txt');
///
/// final IOXFileExtension? ioExtension = file.maybeGetPlatformExtension<IOXFileExtension>();
/// if (ioExtension != null) {
///   print(ioExtension.file.path);
/// }
/// ```
@immutable
class XFile extends XFileEntity {
  /// Constructs a [XFile].
  ///
  /// See [XFile.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  XFile(String uri)
    : this.fromPlatformCreationParams(PlatformXFileCreationParams(uri: uri));

  /// Constructs an [XFile] from creation params for a specific platform.
  ///
  /// {@template cross_file.XFile.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the dart:io implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformXFileCreationParams(uri: 'my/file.txt');
  ///
  /// if (CrossFilePlatform.instance is CrossFileIO) {
  ///   params = IOXFileCreationParams.fromCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final file = XFile.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  XFile.fromPlatformCreationParams(PlatformXFileCreationParams params)
    : this.fromPlatform(PlatformXFile(params));

  /// Constructs a [XFile] from a specific platform implementation.
  const XFile.fromPlatform(PlatformXFile super.platform);

  /// Implementation of [XFile] for the current platform.
  @override
  PlatformXFile get platform => super.platform as PlatformXFile;

  /// Provides a nonnull platform class extension.
  ///
  /// Will throw an exception if the specified platform extension can not be
  /// returned.
  S getPlatformExtension<S extends PlatformXFileExtension>() {
    return platform.extension! as S;
  }

  /// Attempt to provide the platform class extension.
  ///
  /// Returns null if the specified platform extension cannot be retrieved.
  S? maybeGetPlatformExtension<S extends PlatformXFileExtension>() {
    return platform.extension is S ? platform.extension! as S : null;
  }

  /// Date and time when the resource was last modified, if the information is
  /// available.
  ///
  /// Platforms may throw an exception if the information is not available.
  Future<DateTime> lastModified() => platform.lastModified();

  /// The length of the data represented by this uri, in bytes.
  ///
  /// Platforms may throw an exception if the information is not available.
  Future<int> length() => platform.length();

  /// Whether the resource represented by this reference can be read.
  Future<bool> canRead() => platform.canRead();

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
  Stream<List<int>> openRead([int? start, int? end]) =>
      platform.openRead(start, end);

  /// Reads the entire resource contents as a list of bytes.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<Uint8List> readAsBytes() => platform.readAsBytes();

  /// Reads the entire resource contents as a string using the given Encoding.
  ///
  /// Platforms may throw an exception if there is an error opening or reading
  /// the resource.
  Future<String> readAsString({Encoding encoding = utf8}) =>
      platform.readAsString(encoding: encoding);

  /// The name of the resource represented by this object.
  ///
  /// The path is excluded from this value.
  Future<String?> name() => platform.name();
}
