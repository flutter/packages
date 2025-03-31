// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdsManager`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsManagerProxyAPIDelegate: PigeonApiDelegateIMAAdsManager {
  func setDelegate(
    pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager,
    delegate: IMAAdsManagerDelegate?
  ) throws {
    pigeonInstance.delegate = delegate as? AdsManagerDelegateImpl
  }

  func initialize(
    pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager,
    adsRenderingSettings: IMAAdsRenderingSettings?
  ) throws {
    pigeonInstance.initialize(with: adsRenderingSettings)
  }

  func start(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.start()
  }

  func pause(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.pause()
  }

  func skip(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.skip()
  }

  func discardAdBreak(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.discardAdBreak()
  }

  func resume(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.resume()
  }

  func destroy(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.destroy()
  }
}
