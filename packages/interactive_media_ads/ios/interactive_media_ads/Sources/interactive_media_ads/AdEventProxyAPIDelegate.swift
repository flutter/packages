//
//  AdEventProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdEventProxyAPIDelegate: PigeonDelegateIMAAdEvent {
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
