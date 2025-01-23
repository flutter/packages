// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "google-maps-flutter-ios", type: .static, targets: ["google_maps_flutter_ios"])
  ],
  dependencies: [
    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "9.0.0"..<"10.0.0"),
    .package(url: "https://github.com/googlemaps/google-maps-ios-utils", "6.1.0"..<"7.0.0"),
  ],
  targets: [
    .target(
      name: "google_maps_flutter_ios",
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
      exclude: [
        "include/google_maps_flutter_ios-umbrella.h", "include/google_maps_flutter_ios.modulemap",
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/google_maps_flutter_ios")
      ]
    )
  ]
)
