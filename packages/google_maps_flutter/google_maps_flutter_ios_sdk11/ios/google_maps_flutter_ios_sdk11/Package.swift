// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios_sdk11",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "google-maps-flutter-ios-sdk11", targets: ["google_maps_flutter_ios_sdk11"])
  ],
  dependencies: [
    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "11.0.0"..<"12.0.0"),
    // 7.1.2 is the first version to support SDK 11.x. In the past, SDK major version
    // and required iOS minimum versinos have changed without a major version
    // change, so pin an exact version to avoid breakage if the same thing
    // happens again in the future.
    .package(url: "https://github.com/googlemaps/google-maps-ios-utils", exact: "7.1.2"),
  ],
  targets: [
    .target(
      name: "google_maps_flutter_ios_sdk11",
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
      ]
    )
  ]
)
