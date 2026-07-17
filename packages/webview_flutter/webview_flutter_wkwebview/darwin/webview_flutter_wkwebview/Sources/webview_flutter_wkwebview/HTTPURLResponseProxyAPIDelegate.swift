// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `HTTPURLResponse`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class HTTPURLResponseProxyAPIDelegate: PigeonApiDelegateHTTPURLResponse {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiHTTPURLResponse, statusCode: Int64, url: String, httpVersion: String?,
    headerFields: [String: String]?
  ) throws -> HTTPURLResponse {
    let registrar = pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar
    guard let parsedUrl = URL(string: url) else {
      throw registrar.createConstructorNullError(type: URL.self, parameters: ["string": url])
    }
    guard
      let response = HTTPURLResponse(
        url: parsedUrl, statusCode: Int(statusCode), httpVersion: httpVersion,
        headerFields: headerFields)
    else {
      throw registrar.createConstructorNullError(
        type: HTTPURLResponse.self,
        parameters: [
          "url": url, "statusCode": statusCode, "httpVersion": httpVersion,
          "headerFields": headerFields,
        ])
    }
    return response
  }

  func statusCode(pigeonApi: PigeonApiHTTPURLResponse, pigeonInstance: HTTPURLResponse) throws
    -> Int64
  {
    return Int64(pigeonInstance.statusCode)
  }
}
