// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios",
  platforms: [
    .iOS("14.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "google-maps-flutter-ios", type: .static, targets: ["google_maps_flutter_ios"])
  ],
  dependencies: [
    // Allow any version up to the next breaking change after the latest version that
    // has been confirmed to be compatible via an example in examples/. See discussion
    // in https://github.com/flutter/flutter/issues/86820 for why this should be as
    // broad as possible.
    // Versions earlier than 8.4 can't be supported because that's the first version
    // that supports privacy manifests.
//    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "8.4.0"..<"9.0.0")
    .package(url: "https://github.com/dogahe/DogaheMaps", exact: "1.0.26")
  ],
  targets: [
    .target(
      name: "google_maps_flutter_ios",
      dependencies: [
       .product(name: "GoogleMaps", package: "DogaheMaps")
//        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
//        .product(name: "GoogleMapsBase", package: "ios-maps-sdk"),
//        .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
      ],
      exclude: ["include/google_maps_flutter_ios.modulemap"],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/google_maps_flutter_ios")
      ]
    )
  ]
)
