// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
      exclude: ["include/cocoapods_camera_avfoundation.modulemap"],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
