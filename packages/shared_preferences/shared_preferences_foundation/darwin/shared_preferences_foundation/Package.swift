// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "shared_preferences_foundation",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "shared-preferences-foundation", targets: ["shared_preferences_foundation"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "shared_preferences_foundation",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
