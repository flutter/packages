// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `URLResponse`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLResponseProxyAPIDelegate: PigeonApiDelegateURLResponse {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiURLResponse, url: String, mimeType: String?, expectedContentLength: Int64,
    textEncodingName: String?
  ) throws -> URLResponse {
    guard let parsedUrl = URL(string: url) else {
      throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createConstructorNullError(
        type: URL.self, parameters: ["string": url])
    }
    return URLResponse(
      url: parsedUrl, mimeType: mimeType, expectedContentLength: Int(expectedContentLength),
      textEncodingName: textEncodingName)
  }
}
