// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Implementation of `PigeonApiDelegateAssetResourceReader`.
class AssetResourceReaderAPIDelegate: PigeonApiDelegateAssetResourceReader {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiAssetResourceReader) throws
    -> AssetResourceReader
  {
    return AssetResourceReader()
  }

  func openRead(
    pigeonApi: PigeonApiAssetResourceReader, pigeonInstance: AssetResourceReader,
    localIdentifier: String, delegate: AssetResourceReaderDelegate
  ) throws -> Bool {
    return pigeonInstance.openRead(localIdentifier: localIdentifier, delegate: delegate)
  }

  func readBytes(
    pigeonApi: PigeonApiAssetResourceReader, pigeonInstance: AssetResourceReader,
    localIdentifier: String, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    pigeonInstance.readBytes(localIdentifier: localIdentifier) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let bytes):
        completion(.success(FlutterStandardTypedData(bytes: bytes)))
      }
    }

  }
}
