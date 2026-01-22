// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios_sdk9",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "google-maps-flutter-ios-sdk9", type: .static, targets: ["google_maps_flutter_ios_sdk9"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "9.0.0"..<"10.0.0"),
    // 6.1.3+ requires SDK 10.
    .package(url: "https://github.com/googlemaps/google-maps-ios-utils", "6.0.0"..<"6.1.3"),
  ],
  targets: [
    .target(
      name: "google_maps_flutter_ios_sdk9",
      dependencies: [
        .product(
          name: "GoogleMapsUtils",
          package: "google-maps-ios-utils"
        ),
        .product(
          name: "GoogleMaps",
          package: "ios-maps-sdk"
        ),
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/google_maps_flutter_ios_sdk9")
      ]
    )
  ]
)
