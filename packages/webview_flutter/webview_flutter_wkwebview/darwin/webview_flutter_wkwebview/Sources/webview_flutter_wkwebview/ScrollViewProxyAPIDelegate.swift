// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import UIKit
#endif

/// ProxyApi implementation for `UIScrollView`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScrollViewProxyAPIDelegate: PigeonApiDelegateUIScrollView {
  #if os(iOS)
    func getContentOffset(pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView) throws
      -> [Double]
    {
      let offset = pigeonInstance.contentOffset
      return [offset.x, offset.y]
    }

    func scrollBy(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, x: Double, y: Double
    ) throws {
      let offset = pigeonInstance.contentOffset
      pigeonInstance.contentOffset = CGPoint(x: offset.x + x, y: offset.y + y)
    }

    func setContentOffset(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, x: Double, y: Double
    ) throws {
      pigeonInstance.contentOffset = CGPoint(x: x, y: y)
    }

    func setDelegate(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView,
      delegate: UIScrollViewDelegate?
    ) throws {
      pigeonInstance.delegate = delegate
    }

    func setBounces(pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, value: Bool)
      throws
    {
      pigeonInstance.bounces = value
    }

    func setBouncesHorizontally(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, value: Bool
    ) throws {
      if #available(iOS 17.4, *) {
        #if compiler(>=6.0)
          pigeonInstance.bouncesHorizontally = value
        #else
          throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnsupportedVersionError(
            method: "UIScrollView.bouncesHorizontally", versionRequirements: "compiler>=6.0")
        #endif
      } else {
        throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnsupportedVersionError(
          method: "UIScrollView.bouncesHorizontally", versionRequirements: "iOS 17.4")
      }
    }

    func setBouncesVertically(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, value: Bool
    ) throws {
      if #available(iOS 17.4, *) {
        #if compiler(>=6.0)
          pigeonInstance.bouncesVertically = value
        #else
          throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnsupportedVersionError(
            method: "UIScrollView.bouncesVertically", versionRequirements: "compiler>=6.0")
        #endif
      } else {
        throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnsupportedVersionError(
          method: "UIScrollView.bouncesVertically", versionRequirements: "iOS 17.4")
      }
    }

    func setAlwaysBounceVertical(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, value: Bool
    ) throws {
      pigeonInstance.alwaysBounceVertical = value
    }

    func setAlwaysBounceHorizontal(
      pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, value: Bool
    ) throws {
      pigeonInstance.alwaysBounceHorizontal = value
    }
  #endif
}
