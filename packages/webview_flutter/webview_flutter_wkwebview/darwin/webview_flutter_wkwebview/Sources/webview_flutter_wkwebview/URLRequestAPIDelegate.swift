// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for [URLRequest].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLRequestProxyAPIDelegate : PigeonApiDelegateNSURLRequest {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiNSURLRequest, url: String) throws -> NSURLRequest {
    return NSURLRequest(url: URL(string: url)!)
  }

  func getUrl(pigeonApi: PigeonApiNSURLRequest, pigeonInstance: NSURLRequest) throws -> String? {
    return pigeonInstance.url?.absoluteString
  }

  func getHttpMethod(pigeonApi: PigeonApiNSURLRequest, pigeonInstance: NSURLRequest) throws -> String? {
    return pigeonInstance.httpMethod
  }

  func getHttpBody(pigeonApi: PigeonApiNSURLRequest, pigeonInstance: NSURLRequest) throws -> FlutterStandardTypedData? {
    if (pigeonInstance.httpBody != nil) {
      return FlutterStandardTypedData(bytes: pigeonInstance.httpBody!)
    }
    
    return nil
  }

  func getAllHttpHeaderFields(pigeonApi: PigeonApiNSURLRequest, pigeonInstance: NSURLRequest) throws -> [String: String]? {
    return pigeonInstance.allHTTPHeaderFields
  }
}
