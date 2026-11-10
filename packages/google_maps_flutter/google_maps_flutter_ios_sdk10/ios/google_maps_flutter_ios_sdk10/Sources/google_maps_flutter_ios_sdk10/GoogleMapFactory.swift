// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps

class GoogleMapFactory: NSObject, FlutterPlatformViewFactory {
  weak var registrar: FlutterPluginRegistrar?
  static var sharedMapServices = GMSServices.sharedServices()
  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> any FlutterPlatformView
  {
    // Precache shared map services, if needed. Initializing this prepares GMSServices
    // on a background thread controlled by the GoogleMaps framework.
    _ = GoogleMapFactory.sharedMapServices

    return GoogleMapController(
      frame: frame, viewIdentifier: viewId,
      creationParameters: args as! PlatformMapViewCreationParams, registrar: registrar!)
  }

  func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
    return MessagesPigeonCodec.shared
  }
}
