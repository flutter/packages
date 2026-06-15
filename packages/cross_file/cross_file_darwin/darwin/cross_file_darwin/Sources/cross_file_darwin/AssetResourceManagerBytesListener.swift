// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos

class AssetResourceReader {
  var delegate: AssetResourceReaderDelegate?

  func openRead(localIdentifier: String) -> Bool {
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
      }
    }

    return false
  }
}

protocol AssetResourceReaderDelegate {
  func onDataReceived(reader: AssetResourceReader, bytes: Data)
  func onCompletion(reader: AssetResourceReader, error: String?)
}
