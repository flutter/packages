// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "video_player_avfoundation",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "video-player-avfoundation", targets: ["video_player_avfoundation"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "video_player_avfoundation",
      dependencies: [
        .target(name: "video_player_avfoundation_ios", condition: .when(platforms: [.iOS])),
        .target(name: "video_player_avfoundation_macos", condition: .when(platforms: [.macOS])),
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/video_player_avfoundation")
      ]
    ),
    .target(
      name: "video_player_avfoundation_ios",
      cSettings: [
        .headerSearchPath("../video_player_avfoundation/include/video_player_avfoundation")
      ]
    ),
    .target(
      name: "video_player_avfoundation_macos",
      cSettings: [
        .headerSearchPath("../video_player_avfoundation/include/video_player_avfoundation")
      ]
    ),
  ]
)
