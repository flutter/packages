// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdsLoader`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsLoaderProxyAPIDelegate: PigeonApiDelegateIMAAdsLoader {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsLoader, settings: IMASettings?) throws
    -> IMAAdsLoader
  {
    return IMAAdsLoader(settings: settings)
  }

  func contentComplete(pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader) throws {
    pigeonInstance.contentComplete()
  }

  func requestAds(
    pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader, request: IMAAdsRequest
  ) throws {
    pigeonInstance.requestAds(with: request)
  }

  func setDelegate(
    pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader, delegate: IMAAdsLoaderDelegate?
  ) throws {
    pigeonInstance.delegate = delegate
  }
}
