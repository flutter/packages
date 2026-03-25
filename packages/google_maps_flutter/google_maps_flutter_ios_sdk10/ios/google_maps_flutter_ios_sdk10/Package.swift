// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios_sdk10",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "google-maps-flutter-ios-sdk10", type: .static,
      targets: ["google_maps_flutter_ios_sdk10"])
  ],
  dependencies: [
    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "10.0.0"..<"11.0.0"),
    // 6.1.3 switched from GoogleMaps 9.x to 10.x without a major version
    // change, so pin an exact version to avoid breakage if the same thing
    // happens with SDK 11 in the future.
    .package(url: "https://github.com/googlemaps/google-maps-ios-utils", exact: "6.1.3"),
  ],
  targets: [
    .target(
      name: "google_maps_flutter_ios_sdk10",
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
        .headerSearchPath("include/google_maps_flutter_ios_sdk10")
      ]
    )
  ]
)
