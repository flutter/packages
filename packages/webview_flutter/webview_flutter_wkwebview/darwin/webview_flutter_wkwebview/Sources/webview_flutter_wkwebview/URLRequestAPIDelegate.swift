// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for [URLRequest].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLRequestProxyAPIDelegate : PigeonApiDelegateURLRequest {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiURLRequest, url: String) throws -> URLRequestWrapper {
    return URLRequestWrapper(value: URLRequest(url: URL(string: url)!))
  }

  func getUrl(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws -> String? {
    return pigeonInstance.value.url?.absoluteString
  }

  func getHttpMethod(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws -> String? {
    return pigeonInstance.value.httpMethod
  }

  func getHttpBody(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws -> FlutterStandardTypedData? {
    if let httpBody = pigeonInstance.value.httpBody {
      return FlutterStandardTypedData(bytes: httpBody)
    }
    
    return nil
  }

  func getAllHttpHeaderFields(pigeonApi: PigeonApiURLRequest, pigeonInstance: URLRequestWrapper) throws -> [String: String]? {
    return pigeonInstance.value.allHTTPHeaderFields
  }
}
