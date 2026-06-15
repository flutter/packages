// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/cross_file_darwin_apis.g.dart',
    swiftOut: 'darwin/cross_file_darwin/Sources/cross_file_darwin/CrossFileDarwinApis.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Api for getting access to file information.
@ProxyApi()
abstract class AssetResourceReader {
  AssetResourceReader();

  late final void Function(Uint8List bytes) onDataReceived;

  late final void Function(String? error) onCompletion;

  bool openRead(String localIdentifier);
}
