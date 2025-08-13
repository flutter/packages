// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdsRequest`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsRequestProxyAPIDelegate: PigeonApiDelegateIMAAdsRequest {
  /// The current version of the `interactive_media_ads` plugin.
  ///
  /// This must match the version in pubspec.yaml.
  static let pluginVersion = "0.2.6+2"

  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdsRequest, adTagUrl: String, adDisplayContainer: IMAAdDisplayContainer,
    contentPlayhead: IMAContentPlayhead?
  ) throws -> IMAAdsRequest {
    // Add a request agent only if the adTagUrl can append a custom parameter.
    let modifiedURL =
      !adTagUrl.contains("#") && adTagUrl.contains("?")
      ? "\(adTagUrl)&request_agent=Flutter-IMA-\(AdsRequestProxyAPIDelegate.pluginVersion)"
      : adTagUrl

    return IMAAdsRequest(
      adTagUrl: modifiedURL, adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead as? ContentPlayheadImpl, userContext: nil)
  }

  func withAdsResponse(
    pigeonApi: PigeonApiIMAAdsRequest, adsResponse: String,
    adDisplayContainer: IMAAdDisplayContainer, contentPlayhead: (any IMAContentPlayhead)?
  ) throws -> IMAAdsRequest {
    return IMAAdsRequest(
      adsResponse: adsResponse, adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead as? ContentPlayheadImpl, userContext: nil)
  }

  func getAdTagUrl(pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest) throws
    -> String?
  {
    return pigeonInstance.adTagUrl
  }

  func getAdDisplayContainer(pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest)
    throws -> IMAAdDisplayContainer
  {
    return pigeonInstance.adDisplayContainer
  }

  func getAdsResponse(pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest) throws
    -> String?
  {
    return pigeonInstance.adsResponse
  }

  func setAdWillAutoPlay(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, adWillAutoPlay: Bool
  ) throws {
    pigeonInstance.adWillAutoPlay = adWillAutoPlay
  }

  func setAdWillPlayMuted(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, adWillPlayMuted: Bool
  ) throws {
    pigeonInstance.adWillPlayMuted = adWillPlayMuted
  }

  func setContinuousPlayback(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, continuousPlayback: Bool
  ) throws {
    pigeonInstance.continuousPlayback = continuousPlayback
  }

  func setContentDuration(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, duration: Double
  ) throws {
    pigeonInstance.contentDuration = Float(duration)
  }

  func setContentKeywords(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, keywords: [String]?
  ) throws {
    pigeonInstance.contentKeywords = keywords
  }

  func setContentTitle(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, title: String?
  ) throws {
    pigeonInstance.contentTitle = title
  }

  func setContentURL(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, contentURL: String?
  ) throws {
    if let contentURL = contentURL {
      let url = URL(string: contentURL)
      if let url = url {
        pigeonInstance.contentURL = url
      } else {
        throw (pigeonApi.pigeonRegistrar.apiDelegate as! ProxyApiDelegate)
          .createConstructorNullError(type: URL.Type.self, parameters: ["string": contentURL])
      }
    } else {
      pigeonInstance.contentURL = nil
    }
  }

  func setVastLoadTimeout(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, timeout: Double
  ) throws {
    pigeonInstance.vastLoadTimeout = Float(timeout)
  }

  func setLiveStreamPrefetchSeconds(
    pigeonApi: PigeonApiIMAAdsRequest, pigeonInstance: IMAAdsRequest, seconds: Double
  ) throws {
    pigeonInstance.liveStreamPrefetchSeconds = Float(seconds)
  }
}
