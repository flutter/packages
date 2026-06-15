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

private class AssetResourceReaderDelegateImpl: NSObject, AssetResourceReaderDelegate {
  let api: PigeonApiProtocolAssetResourceReader
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolAssetResourceReader, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  func onDataReceived(reader: AssetResourceReader, bytes: Data) {
    let data = FlutterStandardTypedData(bytes: bytes)
    registrar.dispatchOnMainThread { onFailure in
      self.api.onDataReceived(pigeonInstance: reader, bytes: data) { result in
        if case .failure(let error) = result {
          onFailure("AssetResourceReaderDelegate.onDataReceived", error)
        }
      }
    }
  }

  func onCompletion(reader: AssetResourceReader, error: String?) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.onCompletion(pigeonInstance: reader, error: error) { result in
        if case .failure(let error) = result {
          onFailure("AssetResourceReaderDelegate.onCompletion", error)
        }
      }
    }
  }
}

/// Implementation of `PigeonApiDelegateAssetResourceReader`.
class AssetResourceReaderAPIDelegate: PigeonApiDelegateAssetResourceReader {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiAssetResourceReader) throws
    -> AssetResourceReader
  {
    let reader = AssetResourceReader()
    reader.delegate = AssetResourceReaderDelegateImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
    return reader
  }

  func openRead(
    pigeonApi: PigeonApiAssetResourceReader, pigeonInstance: AssetResourceReader,
    localIdentifier: String
  ) throws -> Bool {
    return pigeonInstance.openRead(localIdentifier: localIdentifier)
  }
}
