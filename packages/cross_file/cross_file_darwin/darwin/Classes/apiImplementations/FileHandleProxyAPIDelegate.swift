// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `FileHandle`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FileHandleProxyAPIDelegate: PigeonApiDelegateFileHandle {
  func forReadingFromUrl(pigeonApi: PigeonApiFileHandle, url: String) throws -> FileHandle {
    return FileHandle(url: url)
  }

  func readUpToCount(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle, count: Int64)
    throws -> FlutterStandardTypedData?
  {
    return pigeonInstance.readUpToCount(count: count)
  }

  func readToEnd(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws
    -> FlutterStandardTypedData?
  {
    return pigeonInstance.readToEnd()
  }

  func seek(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle, offset: Int64) throws
    -> Int64
  {
    return pigeonInstance.seek(offset: offset)
  }

  func close(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws {
    pigeonInstance.close()
  }

}
