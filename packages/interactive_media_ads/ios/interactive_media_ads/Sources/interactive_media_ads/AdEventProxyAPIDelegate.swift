// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdEvent`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdEventProxyAPIDelegate: PigeonApiDelegateIMAAdEvent {
  func adData(pigeonApi: PigeonApiIMAAdEvent, pigeonInstance: IMAAdEvent) throws -> [String: Any]? {
    return pigeonInstance.adData
  }

  func type(pigeonApi: PigeonApiIMAAdEvent, pigeonInstance: IMAAdEvent) throws -> AdEventType {
    switch pigeonInstance.type {
    case .AD_BREAK_READY:
      return .adBreakReady
    case .AD_BREAK_FETCH_ERROR:
      return .adBreakFetchError
    case .AD_BREAK_ENDED:
      return .adBreakEnded
    case .AD_BREAK_STARTED:
      return .adBreakStarted
    case .AD_PERIOD_ENDED:
      return .adPeriodEnded
    case .AD_PERIOD_STARTED:
      return .adPeriodStarted
    case .ALL_ADS_COMPLETED:
      return .allAdsCompleted
    case .CLICKED:
      return .clicked
    case .COMPLETE:
      return .completed
    case .CUEPOINTS_CHANGED:
      return .cuepointsChanged
    case .ICON_FALLBACK_IMAGE_CLOSED:
      return .iconFallbackImageClosed
    case .ICON_TAPPED:
      return .iconTapped
    case .FIRST_QUARTILE:
      return .firstQuartile
    case .LOADED:
      return .loaded
    case .LOG:
      return .log
    case .MIDPOINT:
      return .midpoint
    case .PAUSE:
      return .pause
    case .RESUME:
      return .resume
    case .SKIPPED:
      return .skipped
    case .STARTED:
      return .started
    case .STREAM_LOADED:
      return .streamLoaded
    case .STREAM_STARTED:
      return .streamStarted
    case .TAPPED:
      return .tapped
    case .THIRD_QUARTILE:
      return .thirdQuartile
    @unknown default:
      return .unknown
    }
  }

  func typeString(pigeonApi: PigeonApiIMAAdEvent, pigeonInstance: IMAAdEvent) throws -> String {
    return pigeonInstance.typeString
  }
}
