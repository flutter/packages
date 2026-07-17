// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "video_player_avfoundation",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "video-player-avfoundation", targets: ["video_player_avfoundation"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "video_player_avfoundation",
      dependencies: [
        "video_player_avfoundation_objc",
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "video_player_avfoundation_objc",
      dependencies: [
        .target(name: "video_player_avfoundation_ios", condition: .when(platforms: [.iOS])),
        .target(name: "video_player_avfoundation_macos", condition: .when(platforms: [.macOS])),
      ],
      cSettings: [
        .headerSearchPath("include/video_player_avfoundation")
      ]
    ),
    .target(
      name: "video_player_avfoundation_ios",
      cSettings: [
        .headerSearchPath(
          "../video_player_avfoundation_objc/include/video_player_avfoundation_objc")
      ]
    ),
    .target(
      name: "video_player_avfoundation_macos",
      cSettings: [
        .headerSearchPath(
          "../video_player_avfoundation_objc/include/video_player_avfoundation_objc")
      ]
    ),
  ]
)
