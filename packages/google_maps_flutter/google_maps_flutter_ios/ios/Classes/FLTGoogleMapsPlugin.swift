// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps

public class GoogleMapsPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = GoogleMapFactory(registrar: registrar)
    registrar.register(
      factory, withId: "plugins.flutter.dev/google_maps_ios",
      gestureRecognizersBlockingPolicy:
        FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
  }

}

class GoogleMapFactory: NSObject, FlutterPlatformViewFactory {
  weak var registrar: FlutterPluginRegistrar?
  static var sharedMapServices = GMSServices()
  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> any FlutterPlatformView
  {
    // Precache shared map services, if needed. Initializing this prepares GMSServices
    // on a background thread controlled by the GoogleMaps framework.
    _ = GoogleMapFactory.sharedMapServices

    return FLTGoogleMapController(
      frame: frame, viewIdentifier: viewId,
      creationParameters: args as! FGMPlatformMapViewCreationParams, registrar: registrar!)
  }

  func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
    return FGMGetMessagesCodec()
  }
}
