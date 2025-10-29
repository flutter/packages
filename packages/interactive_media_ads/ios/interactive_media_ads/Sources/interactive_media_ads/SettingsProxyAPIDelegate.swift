// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi implementation for `IMASettings`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class SettingsProxyAPIDelegate: PigeonApiDelegateIMASettings {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMASettings) throws -> IMASettings {
    return IMASettings()
  }

  func setPPID(pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, ppid: String?) throws {
    pigeonInstance.ppid = ppid
  }

  func setLanguage(pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, language: String)
    throws
  {
    pigeonInstance.language = language
  }

  func setMaxRedirects(pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, max: Int64)
    throws
  {
    pigeonInstance.maxRedirects = UInt(max)
  }

  func setFeatureFlags(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, flags: [String: String]
  ) throws {
    pigeonInstance.featureFlags = flags
  }

  func setEnableBackgroundPlayback(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, enabled: Bool
  ) throws {
    pigeonInstance.enableBackgroundPlayback = enabled
  }

  func setAutoPlayAdBreaks(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, autoPlay: Bool
  ) throws {
    pigeonInstance.autoPlayAdBreaks = autoPlay
  }

  func setDisableNowPlayingInfo(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, disable: Bool
  ) throws {
    pigeonInstance.disableNowPlayingInfo = disable
  }

  func setPlayerType(pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, type: String?)
    throws
  {
    pigeonInstance.playerType = type
  }

  func setPlayerVersion(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, version: String?
  ) throws {
    pigeonInstance.playerVersion = version
  }

  func setSessionID(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, sessionID: String?
  ) throws {
    pigeonInstance.sessionID = sessionID
  }

  func setSameAppKeyEnabled(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, enabled: Bool
  ) throws {
    pigeonInstance.sameAppKeyEnabled = enabled
  }

  func setEnableDebugMode(
    pigeonApi: PigeonApiIMASettings, pigeonInstance: IMASettings, enable: Bool
  ) throws {
    pigeonInstance.enableDebugMode = enable
  }
}
