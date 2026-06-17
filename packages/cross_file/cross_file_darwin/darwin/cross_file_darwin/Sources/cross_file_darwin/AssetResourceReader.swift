// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos

/// Class for handling an instance of asynchronously reading bytes from
/// `PHAssetResourceManager.requestDataForAssetResource`.
class AssetResourceReader {
  /// Handles the bytes read.
  var delegate: AssetResourceReaderDelegate?

  /// Begin reading bytes from PHAssetResource with `localIdentifier`.
  func startRead(localIdentifier: String) -> Bool {
    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
    if let asset = assets.firstObject {
      let resources = PHAssetResource.assetResources(for: asset)
      if let resource = resources.first {
        let resourceManager = PHAssetResourceManager.default()

        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true

        resourceManager.requestData(for: resource, options: options) { data in
          DispatchQueue.main.async {
            self.delegate?.onDataReceived(reader: self, bytes: data)
          }
        } completionHandler: { error in
          DispatchQueue.main.async {
            self.delegate?.onCompletion(reader: self, error: error?.localizedDescription)
          }
        }
        
        return true
      }
    }

    return false
  }
}

/// Handles bytes read from calling `AssetResourceReader.startRead`.
protocol AssetResourceReaderDelegate {
  /// Provides the requested data.
  ///
  /// Called multiple times until all bytes are received.
  ///
  /// Corresponds to the `dataReceivedHandler` parameter for
  /// `PHAssetResourceManager.requestDataForAssetResource`.
  func onDataReceived(reader: AssetResourceReader, bytes: Data)


  /// Start reading bytes from the asset with the given identifier.
  ///
  /// Returns false if the resource for the identifier could not be accessed or
  /// found. Returns true if the resource can be successfully accessed.
  ///
  /// Bytes are passed to `onDataReceived` and the request is completed when
  /// `onCompletion` is called.
  func onCompletion(reader: AssetResourceReader, error: String?)
}
