// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_maps_flutter_ios_sdk11",
  platforms: [
    // Currently this package only allows up through Google Maps SDK 11.2.0, which still
    // supports iOS 16, but it is versioned as iOS 17 now to allow including 11.3.0 when
    // possible (see comments below) without breaking plugin clients.
    .iOS(.v17)
  ],
  products: [
    .library(name: "google-maps-flutter-ios-sdk11", targets: ["google_maps_flutter_ios_sdk11"])
  ],
  dependencies: [
    // Google Maps SDK 11.3.0 dropped iOS 16 support in a patch release, which broke
    // GoogleMapsUtils (see https://github.com/googlemaps/google-maps-ios-utils/issues/582),
    // so for now only 11.0-11.2 are usable with the utils library. Once a new utils release
    // happens, this can be expanded to include 11.3.0 along with updating the utils pin below.
    // To avoid the possibility of client build breakage in the future if the Google Maps SDK
    // drops iOS version support in a minor release again, this should always use a tight upper
    // bound, which is manually rolled forward to include new minor releases once they are known
    // to be compatible.
    .package(url: "https://github.com/googlemaps/ios-maps-sdk", "11.0.0"..<"11.3.0"),
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
