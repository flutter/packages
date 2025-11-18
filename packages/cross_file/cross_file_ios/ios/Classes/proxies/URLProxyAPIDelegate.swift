// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

/// ProxyApi implementation for `URL`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLProxyAPIDelegate : PigeonApiDelegateURL {
  func fileURLWithPath(pigeonApi: PigeonApiURL, path: String) throws -> URL? {
    return URL(fileURLWithPath: path)
  }
  
  func resolvingBookmarkData(pigeonApi: PigeonApiURL, data: FlutterStandardTypedData, options: [URLBookmarkResolutionOptions], relativeTo: URL?) throws -> URLResolvingBookmarkDataResponse {
    var isStale: Bool = true
    let url: URL = try URL(resolvingBookmarkData: data.data, bookmarkDataIsStale: &isStale)
    let attr = try FileManager.default.attributesOfItem(atPath: url.path)
    print(attr[FileAttributeKey.modificationDate] as? Date as Any)
    print(FileManager.default.fileExists(atPath: url.path))
    return URLResolvingBookmarkDataResponse(url: url, isStale: isStale)
  }
  
  func bookmarkData(pigeonApi: PigeonApiURL, pigeonInstance: URL, options: [URLBookmarkCreationOptions], keys: [URLResourceKeyEnum]?, relativeTo: URL?) throws -> FlutterStandardTypedData {
    let data = try pigeonInstance.bookmarkData(
      options: [],
      includingResourceValuesForKeys: nil,
      relativeTo: relativeTo
    )
    
    return FlutterStandardTypedData(bytes: data)
  }
  
  func startAccessingSecurityScopedResource(pigeonApi: PigeonApiURL, pigeonInstance: URL) throws -> Bool {
    return pigeonInstance.startAccessingSecurityScopedResource()
  }
  
  func stopAccessingSecurityScopedResource(pigeonApi: PigeonApiURL, pigeonInstance: URL) throws {
    pigeonInstance.stopAccessingSecurityScopedResource()
  }

}
