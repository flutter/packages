// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// Implementation of `IMAContentPlayhead` with a settable time interval.
class ContentPlayheadImpl: NSObject, IMAContentPlayhead {
  var currentTime: TimeInterval = 0.0
}

/// ProxyApi delegate implementation for `IMAContentPlayhead`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class ContentPlayheadProxyAPIDelegate: PigeonApiDelegateIMAContentPlayhead {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAContentPlayhead) throws -> IMAContentPlayhead
  {
    return ContentPlayheadImpl()
  }

  // This is not an actual method on IMAContentPlayhead, but added so it can handle the sync callback.
  func setCurrentTime(
    pigeonApi: PigeonApiIMAContentPlayhead, pigeonInstance: IMAContentPlayhead, timeInterval: Double
  ) throws {
    (pigeonInstance as! ContentPlayheadImpl).currentTime = timeInterval
  }
}
