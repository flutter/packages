// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `HTTPCookie`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class HTTPCookieProxyAPIDelegate: PigeonApiDelegateHTTPCookie {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiHTTPCookie, properties: [HttpCookiePropertyKey: Any]
  ) throws -> HTTPCookie {
    let registrar = pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar

    let keyValueTuples = try! properties.map<[(HTTPCookiePropertyKey, Any)], PigeonError> {
      key, value in

      let newKey: HTTPCookiePropertyKey
      switch key {
      case .comment:
        newKey = .comment
      case .commentUrl:
        newKey = .commentURL
      case .discard:
        newKey = .discard
      case .domain:
        newKey = .domain
      case .expires:
        newKey = .expires
      case .maximumAge:
        newKey = .maximumAge
      case .name:
        newKey = .name
      case .originUrl:
        newKey = .originURL
      case .path:
        newKey = .path
      case .port:
        newKey = .port
      case .secure:
        newKey = .secure
      case .value:
        newKey = .value
      case .version:
        newKey = .version
      case .sameSitePolicy:
        if #available(iOS 13.0, macOS 10.15, *) {
          newKey = .sameSitePolicy
        } else {
          throw
            registrar
            .createUnsupportedVersionError(
              method: "HTTPCookiePropertyKey.sameSitePolicy",
              versionRequirements: "iOS 13.0, macOS 10.15")
        }
      case .unknown:
        throw registrar.createUnknownEnumError(
          withEnum: key)
      }

      return (newKey, value)
    }

    let nativeProperties = Dictionary(uniqueKeysWithValues: keyValueTuples)
    let cookie = HTTPCookie(properties: nativeProperties)
    if let cookie = cookie {
      return cookie
    } else {
      throw registrar.createConstructorNullError(
        type: HTTPCookie.self, parameters: ["properties": nativeProperties])
    }
  }

  func getProperties(pigeonApi: PigeonApiHTTPCookie, pigeonInstance: HTTPCookie) throws
    -> [HttpCookiePropertyKey: Any]?
  {
    if pigeonInstance.properties == nil {
      return nil
    }

    let keyValueTuples = pigeonInstance.properties!.map { key, value in
      let newKey: HttpCookiePropertyKey
      if #available(iOS 13.0, macOS 10.15, *), key == .sameSitePolicy {
        newKey = .sameSitePolicy
      } else {
        switch key {
        case .comment:
          newKey = .comment
        case .commentURL:
          newKey = .commentUrl
        case .discard:
          newKey = .discard
        case .domain:
          newKey = .domain
        case .expires:
          newKey = .expires
        case .maximumAge:
          newKey = .maximumAge
        case .name:
          newKey = .name
        case .originURL:
          newKey = .originUrl
        case .path:
          newKey = .path
        case .port:
          newKey = .port
        case .secure:
          newKey = .secure
        case .value:
          newKey = .value
        case .version:
          newKey = .version
        default:
          newKey = .unknown
        }
      }

      return (newKey, value)
    }

    return Dictionary(uniqueKeysWithValues: keyValueTuples)
  }
}
