// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import Foundation
#else
  #error("Unsupported platform.")
#endif

/// ProxyApi implementation for `URLRequest`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLRequestProxyAPIDelegate: PigeonApiDelegateURLRequest {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiURLRequest, url: String) throws
    -> URLRequestWrapper
  {
    let urlObject = URL(string: url)
    if let urlObject = urlObject {
      return URLRequestWrapper(URLRequest(url: urlObject))
    } else {
      let registrar = pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar
      throw registrar.createConstructorNullError(type: NSURL.self, parameters: ["string": url])
    }
  }

  func setHttpMethod(
    pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper, method: String?
  ) throws {
    pigeonInstance.value.httpMethod = method
  }

  func setHttpBody(
    pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper,
    body: FlutterStandardTypedData?
  ) throws {
    pigeonInstance.value.httpBody = body?.data
  }

  func setAllHttpHeaderFields(
    pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper, fields: [String: String]?
  ) throws {
    pigeonInstance.value.allHTTPHeaderFields = fields
  }

  func getUrl(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws -> String? {
    return pigeonInstance.value.url?.absoluteString
  }

  func getHttpMethod(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws
    -> String?
  {
    return pigeonInstance.value.httpMethod
  }

  func getHttpBody(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws
    -> FlutterStandardTypedData?
  {
    if let httpBody = pigeonInstance.value.httpBody {
      return FlutterStandardTypedData(bytes: httpBody)
    }

    return nil
  }

  func getAllHttpHeaderFields(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper)
    throws -> [String: String]?
  {
    return pigeonInstance.value.allHTTPHeaderFields
  }
}
