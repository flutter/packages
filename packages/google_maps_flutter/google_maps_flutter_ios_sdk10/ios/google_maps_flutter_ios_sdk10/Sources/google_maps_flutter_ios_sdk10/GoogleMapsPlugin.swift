// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps

public class GoogleMapsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = GoogleMapFactory(registrar: registrar)
    registrar.register(
      factory,
      withId: "plugins.flutter.dev/google_maps_ios",
      gestureRecognizersBlockingPolicy:
        FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
    GMSServices.addInternalUsageAttributionID("gmp_flutter_googlemapsflutter_ios")
  }
}
