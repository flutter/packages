// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds
import UIKit

/// ProxyApi implementation for [IMAFriendlyObstruction].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FriendlyObstructionProxyAPIDelegate: PigeonApiDelegateIMAFriendlyObstruction {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAFriendlyObstruction, view: UIView, purpose: FriendlyObstructionPurpose,
    detailedReason: String?
  ) throws -> IMAFriendlyObstruction {
    var nativePurpose: IMAFriendlyObstructionPurpose
    switch purpose {
    case .mediaControls:
      nativePurpose = IMAFriendlyObstructionPurpose.mediaControls
    case .closeAd:
      nativePurpose = IMAFriendlyObstructionPurpose.closeAd
    case .notVisible:
      nativePurpose = IMAFriendlyObstructionPurpose.notVisible
    case .other:
      nativePurpose = IMAFriendlyObstructionPurpose.other
    case .unknown:
      throw (pigeonApi.pigeonRegistrar.apiDelegate as! ProxyApiDelegate).createUnknownEnumError(
        withEnum: purpose)
    }
    return IMAFriendlyObstruction(
      view: view, purpose: nativePurpose, detailedReason: detailedReason)
  }

  func view(pigeonApi: PigeonApiIMAFriendlyObstruction, pigeonInstance: IMAFriendlyObstruction)
    throws -> UIView
  {
    return pigeonInstance.view
  }

  func purpose(pigeonApi: PigeonApiIMAFriendlyObstruction, pigeonInstance: IMAFriendlyObstruction)
    throws -> FriendlyObstructionPurpose
  {
    switch pigeonInstance.purpose {
    case .mediaControls:
      return .mediaControls
    case .closeAd:
      return .closeAd
    case .notVisible:
      return .notVisible
    case .other:
      return .other
    @unknown default:
      return .unknown
    }
  }

  func detailedReason(
    pigeonApi: PigeonApiIMAFriendlyObstruction, pigeonInstance: IMAFriendlyObstruction
  ) throws -> String? {
    return pigeonInstance.detailedReason
  }
}
