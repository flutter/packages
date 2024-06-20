// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v20.1.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class PigeonError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "PigeonError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
      }
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// Possible error types while loading or playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAErrorType.html.
enum AdErrorType: Int {
  /// An error occurred while loading the ads.
  case loadingFailed = 0
  /// An error occurred while playing the ads.
  case adPlayingFailed = 1
  /// An unexpected error occurred while loading or playing the ads.
  ///
  /// This may mean that the SDK wasn’t loaded properly or the wrapper doesn't
  /// recognize this value.
  case unknown = 2
}

/// Possible error codes raised while loading or playing ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAErrorCode.html.
enum AdErrorCode: Int {
  /// The ad slot is not visible on the page.
  case adslotNotVisible = 0
  /// Generic invalid usage of the API.
  case apiError = 1
  /// A companion ad failed to load or render.
  case companionAdLoadingFailed = 2
  /// Content playhead was not passed in, but list of ads has been returned from
  /// the server.
  case contentPlayheadMissing = 3
  /// There was an error loading the ad.
  case failedLoadingAd = 4
  /// There was a problem requesting ads from the server.
  case failedToRequestAds = 5
  /// Invalid arguments were provided to SDK methods.
  case invalidArguments = 6
  /// The version of the runtime is too old.
  case osRuntimeTooOld = 7
  /// Ads list response was malformed.
  case playlistMalformedResponse = 8
  /// Listener for at least one of the required vast events was not added.
  case requiredListenersNotAdded = 9
  /// There was an error initializing the stream.
  case streamInitializationFailed = 10
  /// An unexpected error occurred and the cause is not known.
  case unknownError = 11
  /// No assets were found in the VAST ad response.
  case vastAssetNotFound = 12
  /// A VAST response containing a single `<VAST>` tag with no child tags.
  case vastEmptyResponse = 13
  /// At least one VAST wrapper loaded and a subsequent wrapper or inline ad
  /// load has resulted in a 404 response code.
  case vastInvalidUrl = 14
  /// Assets were found in the VAST ad response for a linear ad, but none of
  /// them matched the video player's capabilities.
  case vastLinearAssetMismatch = 15
  /// The VAST URI provided, or a VAST URI provided in a subsequent Wrapper
  /// element, was either unavailable or reached a timeout, as defined by the
  /// video player.
  case vastLoadTimeout = 16
  /// The ad response was not recognized as a valid VAST ad.
  case vastMalformedResponse = 17
  /// Failed to load media assets from a VAST response.
  case vastMediaLoadTimeout = 18
  /// The maximum number of VAST wrapper redirects has been reached.
  case vastTooManyRedirects = 19
  /// Trafficking error.
  ///
  /// Video player received an ad type that it was not expecting and/or cannot
  /// display.
  case vastTraffickingError = 20
  /// Another VideoAdsManager is still using the video.
  case videoElementUsed = 21
  /// A video element was not specified where it was required.
  case videoElementRequired = 22
  /// There was an error playing the video ad.
  case videoPlayError = 23
}

/// Different event types sent by the IMAAdsManager to its delegate.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Enums/IMAAdEventType.html.
enum AdEventType: Int {
  /// Fired the first time each ad break ends.
  case adBreakEnded = 0
  /// Fired when an ad break will not play back any ads.
  case adBreakFetchError = 1
  /// Fired when an ad break is ready.
  case adBreakReady = 2
  /// Fired first time each ad break begins playback.
  case adBreakStarted = 3
  /// Fired every time the stream switches from advertising or slate to content.
  case adPeriodEnded = 4
  /// Fired every time the stream switches from content to advertising or slate.
  case adPeriodStarted = 5
  /// All valid ads managed by the ads manager have completed or the ad response
  /// did not return any valid ads.
  case allAdsCompleted = 6
  /// Fired when an ad is clicked.
  case clicked = 7
  /// Single ad has finished.
  case completed = 8
  /// Cuepoints changed for VOD stream (only used for dynamic ad insertion).
  case cuepointsChanged = 9
  /// First quartile of a linear ad was reached.
  case firstQuartile = 10
  /// The user has closed the icon fallback image dialog.
  case iconFallbackImageClosed = 11
  /// The user has tapped an ad icon.
  case iconTapped = 12
  /// An ad was loaded.
  case loaded = 13
  /// A log event for the ads being played.
  case log = 14
  /// Midpoint of a linear ad was reached.
  case midpoint = 15
  /// Ad paused.
  case pause = 16
  /// Ad resumed.
  case resume = 17
  /// Fired when an ad was skipped.
  case skipped = 18
  /// Fired when an ad starts playing.
  case started = 19
  /// Stream request has loaded (only used for dynamic ad insertion).
  case streamLoaded = 20
  /// Stream has started playing (only used for dynamic ad insertion).
  case streamStarted = 21
  /// Ad tapped.
  case tapped = 22
  /// Third quartile of a linear ad was reached..
  case thirdQuartile = 23
  /// The event type is not recognized by this wrapper.
  case unknown = 24
}
private class InteractiveMediaAdsLibraryPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      var enumResult: AdErrorType? = nil
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as? Int)
      if let enumResultAsInt = enumResultAsInt {
        enumResult = AdErrorType(rawValue: enumResultAsInt)
      }
      return enumResult
    case 130:
      var enumResult: AdErrorCode? = nil
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as? Int)
      if let enumResultAsInt = enumResultAsInt {
        enumResult = AdErrorCode(rawValue: enumResultAsInt)
      }
      return enumResult
    case 131:
      var enumResult: AdEventType? = nil
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as? Int)
      if let enumResultAsInt = enumResultAsInt {
        enumResult = AdEventType(rawValue: enumResultAsInt)
      }
      return enumResult
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class InteractiveMediaAdsLibraryPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? AdErrorType {
      super.writeByte(129)
      super.writeValue(value.rawValue)
    } else if let value = value as? AdErrorCode {
      super.writeByte(130)
      super.writeValue(value.rawValue)
    } else if let value = value as? AdEventType {
      super.writeByte(131)
      super.writeValue(value.rawValue)
    } else {
      super.writeValue(value)
    }
  }
}

private class InteractiveMediaAdsLibraryPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return InteractiveMediaAdsLibraryPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return InteractiveMediaAdsLibraryPigeonCodecWriter(data: data)
  }
}

class InteractiveMediaAdsLibraryPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = InteractiveMediaAdsLibraryPigeonCodec(readerWriter: InteractiveMediaAdsLibraryPigeonCodecReaderWriter())
}

