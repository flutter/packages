//
//  ContentPlayheadProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

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

  // This is not an actual, but added so it can handle the sync callback.
  func setCurrentTime(
    pigeonApi: PigeonApiIMAContentPlayhead, pigeonInstance: IMAContentPlayhead, timeInterval: Double
  ) throws {
    (pigeonInstance as! ContentPlayheadImpl).currentTime = timeInterval
  }
}
