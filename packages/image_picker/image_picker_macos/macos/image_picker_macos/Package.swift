// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "image_picker_macos",
  platforms: [
    .macOS("10.11")
  ],
  products: [
    .library(name: "image-picker-macos", targets: ["image_picker_macos"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "image_picker_macos",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
