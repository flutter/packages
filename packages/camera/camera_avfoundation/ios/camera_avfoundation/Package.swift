// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "camera_avfoundation",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(
      name: "camera-avfoundation", targets: ["camera_avfoundation"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "camera_avfoundation",
      path: "Sources/camera_avfoundation",
      resources: [
        .process("Resources")
      ]
    )
  ]
)
