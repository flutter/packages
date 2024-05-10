// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "quick_actions_ios",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "quick-actions-ios", targets: ["quick_actions_ios"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "quick_actions_ios",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
