// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/cross_file_darwin_apis.g.dart',
    swiftOut:
        'darwin/cross_file_darwin/Sources/cross_file_darwin/CrossFileDarwinApis.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Api for getting access to file information.
@HostApi()
abstract class CrossFileDarwinApi {
  /// In an app that has adopted App Sandbox, makes the resource pointed to by a
  /// security-scoped URL available to the app.
  bool startAccessingSecurityScopedResource(String url);

  /// In an app that adopts App Sandbox, revokes access to the resource pointed
  /// to by a security-scoped URL.
  void stopAccessingSecurityScopedResource(String url);

  /// Whether the native FileManager is able to read a specified file.
  bool isReadableFile(String url);
  //
  // /// Date and time when the resource was last modified, if the information is
  // /// available.
  // ///
  // /// Returns null if file doesn't exist or information is not available.
  // @async
  // int? lastModified(String identifier);
  //
  // /// The length of the data represented by this uri, in bytes.
  // ///
  // /// Returns null if file doesn't exist or information is not available.
  // //Future<int?> length(String identifier);
  //
  // /// Reads the entire resource contents as a list of bytes.
  // ///
  // /// Platforms may throw an exception if there is an error opening or reading
  // /// the resource.
  // @async
  // Uint8List readAsBytes(String identifier);
  //
  // /// The name of the resource represented by this object.
  // ///
  // /// The path is excluded from this value.
  // ///
  // /// Returns null if file doesn't exist or information is not available.
  // @async
  // String? name(String identifier);
}
