// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "camera_avfoundation",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "camera-avfoundation", targets: ["camera_avfoundation"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "camera_avfoundation",
      dependencies: [],
      exclude: ["include/camera_avfoundation-umbrella.h", "include/CameraPlugin.modulemap"],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/camera_avfoundation")
      ]
    )
  ]
)
