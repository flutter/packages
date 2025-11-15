// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Flutter

/// ProxyApi implementation for `FileManager`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FileManagerProxyAPIDelegate : PigeonApiDelegateFileManager {
  func defaultManager(pigeonApi: PigeonApiFileManager) -> FileManager {
    return FileManager.default
  }

  func fileExists(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String) throws -> Bool {
    return pigeonInstance.fileExists(atPath: atPath)
  }

  func isReadableFile(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String) throws -> Bool {
    return pigeonInstance.isReadableFile(atPath: atPath)
  }

  func contents(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String) throws -> FlutterStandardTypedData? {
    let data = pigeonInstance.contents(atPath: atPath)
    if let data = data {
      return FlutterStandardTypedData(bytes: data)
    }
    
    return nil
  }
}
