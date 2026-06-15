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
/// Class for handling an instance of asynchronously reading bytes from
/// [PHAssetResourceManager.requestDataForAssetResource](https://developer.apple.com/documentation/photos/phassetresourcemanager/requestdata(for:options:datareceivedhandler:completionhandler:)?language=objc).
@ProxyApi()
abstract class AssetResourceReader {
  AssetResourceReader();

  /// Provides the requested data.
  ///
  /// Called multiple times until all bytes are received.
  ///
  /// Corresponds to the `dataReceivedHandler` parameter for
  /// `PHAssetResourceManager.requestDataForAssetResource`.
  late final void Function(Uint8List bytes) onDataReceived;

  /// Indicates the request for data has completed.
  ///
  /// Called once after the request has been fulfilled or has failed.
  ///
  /// Corresponds to the `completionHandler` parameter for
  /// `PHAssetResourceManager.requestDataForAssetResource`.
  late final void Function(String? error) onCompletion;

  /// Start reading bytes from the asset with the given identifier.
  ///
  /// Returns false if the resource for the identifier could not be accessed or
  /// found. Returns true if the resource can be successfully accessed.
  ///
  /// Bytes are passed to `onDataReceived` and the request is completed when
  /// `onCompletion` is called.
  bool startRead(String localIdentifier);
}
