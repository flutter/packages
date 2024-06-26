// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class ContentPlayheadImpl: NSObject, IMAContentPlayhead {
  var currentTime: TimeInterval = 0.0
}

class ContentPlayheadProxyAPIDelegate: PigeonDelegateIMAContentPlayhead {
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
