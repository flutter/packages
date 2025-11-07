// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "interactive_media_ads",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(name: "interactive-media-ads", targets: ["interactive_media_ads"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios",
      // 3.28.10 requires iOS 15+.
      "3.23.0"..<"3.28.10")
  ],
  targets: [
    .target(
      name: "interactive_media_ads",
      dependencies: [
        .product(
          name: "GoogleInteractiveMediaAds",
          package: "swift-package-manager-google-interactive-media-ads-ios")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
