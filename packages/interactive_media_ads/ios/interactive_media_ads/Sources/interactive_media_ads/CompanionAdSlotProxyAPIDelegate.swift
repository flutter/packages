// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds
import UIKit

/// ProxyApi implementation for [IMACompanionAdSlot].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class CompanionAdSlotProxyAPIDelegate: PigeonApiDelegateIMACompanionAdSlot {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMACompanionAdSlot, view: UIView) throws
    -> IMACompanionAdSlot
  {
    return IMACompanionAdSlot(view: view)
  }

  func size(pigeonApi: PigeonApiIMACompanionAdSlot, view: UIView, width: Int64, height: Int64)
    throws -> IMACompanionAdSlot
  {
    return IMACompanionAdSlot(view: view, width: Int(width), height: Int(height))
  }

  func view(pigeonApi: PigeonApiIMACompanionAdSlot, pigeonInstance: IMACompanionAdSlot) throws
    -> UIView
  {
    return pigeonInstance.view
  }

  func setDelegate(
    pigeonApi: PigeonApiIMACompanionAdSlot, pigeonInstance: IMACompanionAdSlot,
    delegate: IMACompanionDelegate?
  ) throws {
    pigeonInstance.delegate = delegate
  }

  func width(pigeonApi: PigeonApiIMACompanionAdSlot, pigeonInstance: IMACompanionAdSlot) throws
    -> Int64
  {
    return Int64(pigeonInstance.width)
  }

  func height(pigeonApi: PigeonApiIMACompanionAdSlot, pigeonInstance: IMACompanionAdSlot) throws
    -> Int64
  {
    return Int64(pigeonInstance.height)
  }
}
