// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// ProxyApi implementation for `WKURLSchemeTask`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLSchemeTaskProxyAPIDelegate: PigeonApiDelegateWKURLSchemeTask {
  func request(pigeonApi: PigeonApiWKURLSchemeTask, pigeonInstance: WKURLSchemeTask) throws
    -> URLRequestWrapper
  {
    return URLRequestWrapper(pigeonInstance.request)
  }

  func didReceiveResponse(
    pigeonApi: PigeonApiWKURLSchemeTask, pigeonInstance: WKURLSchemeTask, response: URLResponse
  ) throws {
    if URLSchemeTaskState.isStopped(pigeonInstance) {
      return
    }
    pigeonInstance.didReceive(response)
  }

  func didReceiveData(
    pigeonApi: PigeonApiWKURLSchemeTask, pigeonInstance: WKURLSchemeTask,
    data: FlutterStandardTypedData
  ) throws {
    if URLSchemeTaskState.isStopped(pigeonInstance) {
      return
    }
    pigeonInstance.didReceive(data.data)
  }

  func didFinish(pigeonApi: PigeonApiWKURLSchemeTask, pigeonInstance: WKURLSchemeTask) throws {
    if URLSchemeTaskState.isStopped(pigeonInstance) {
      return
    }
    pigeonInstance.didFinish()
  }

  func didFailWithError(
    pigeonApi: PigeonApiWKURLSchemeTask, pigeonInstance: WKURLSchemeTask, error: NSError
  ) throws {
    if URLSchemeTaskState.isStopped(pigeonInstance) {
      return
    }
    pigeonInstance.didFailWithError(error)
  }
}
