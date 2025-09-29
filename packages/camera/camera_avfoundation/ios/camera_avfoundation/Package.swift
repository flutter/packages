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
      name: "camera-avfoundation", targets: ["camera_avfoundation", "camera_avfoundation_objc"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "camera_avfoundation",
      dependencies: ["camera_avfoundation_objc"],
      path: "Sources/camera_avfoundation",
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "camera_avfoundation_objc",
      dependencies: [],
      path: "Sources/camera_avfoundation_objc",
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/camera_avfoundation")
      ]
    ),
  ]
)
