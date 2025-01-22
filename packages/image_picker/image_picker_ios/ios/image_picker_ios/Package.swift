// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "image_picker_ios",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "image-picker-ios", targets: ["image_picker_ios"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "image_picker_ios",
      dependencies: [],
      exclude: ["include/image_picker_ios-umbrella.h", "include/ImagePickerPlugin.modulemap"],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/image_picker_ios")
      ]
    )
  ]
)
