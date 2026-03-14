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
}
