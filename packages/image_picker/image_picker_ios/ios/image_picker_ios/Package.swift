// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "image_picker_ios",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(name: "image-picker-ios", targets: ["image_picker_ios"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "image_picker_ios",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ],
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
