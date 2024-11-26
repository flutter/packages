// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit
import WebKit


/// ProxyApi implementation for [WKNavigationAction].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationActionProxyAPIDelegate : PigeonApiDelegateWKNavigationAction {
  func request(pigeonApi: PigeonApiWKNavigationAction, pigeonInstance: WKNavigationAction) throws -> URLRequestWrapper {
    return URLRequestWrapper(value: pigeonInstance.request)
  }

  func targetFrame(pigeonApi: PigeonApiWKNavigationAction, pigeonInstance: WKNavigationAction) throws -> WKFrameInfo {
    return pigeonInstance.targetFrame
  }

  func navigationType(pigeonApi: PigeonApiWKNavigationAction, pigeonInstance: WKNavigationAction) throws -> NavigationType {
    switch pigeon_instance.navigationType {
      case .linkActivated
        return .linkActivated
            case .submitted
        return .submitted
            case .backForward
        return .backForward
            case .reload
        return .reload
            case .formResubmitted
        return .formResubmitted
            case .other
        return .other
            @unknown default:
        return .unknown
      
    }
  }

}
