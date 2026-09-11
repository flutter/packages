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
  let api: PigeonApiProtocolAssetResourceReaderDelegate
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolAssetResourceReaderDelegate, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  func onDataReceived(reader: AssetResourceReader, bytes: Data) {
    let data = FlutterStandardTypedData(bytes: bytes)
    registrar.dispatchOnMainThread { onFailure in
      self.api.onDataReceived(pigeonInstance: self, bytes: data) { result in
        if case .failure(let error) = result {
          onFailure("AssetResourceReaderDelegate.onDataReceived", error)
        }
      }
    }
  }

  func onCompletion(reader: AssetResourceReader, error: String?) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.onCompletion(pigeonInstance: self, error: error) { result in
        if case .failure(let error) = result {
          onFailure("AssetResourceReaderDelegate.onCompletion", error)
        }
      }
    }
  }
}

/// Implementation of `PigeonApiDelegateAssetResourceReaderDelegate`.
class AssetResourceReaderDelegateAPIDelegate: PigeonApiDelegateAssetResourceReaderDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiAssetResourceReaderDelegate) throws
    -> AssetResourceReaderDelegate
  {
    return AssetResourceReaderDelegateImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }
}
