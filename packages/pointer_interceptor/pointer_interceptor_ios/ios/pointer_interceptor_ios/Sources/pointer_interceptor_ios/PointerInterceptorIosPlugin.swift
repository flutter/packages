// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import UIKit

public class PointerInterceptorIosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(
      PointerInterceptorFactory(), withId: "plugins.flutter.dev/pointer_interceptor_ios")
  }
}
