// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
    name: "cross_file_darwin",
    platforms: [
      .iOS("13.0"),
      .macOS("10.15"),
    ],
    products: [
      .library(name: "cross-file-darwin", targets: ["cross_file_darwin"])
    ],
    dependencies: [],
    targets: [
      .target(
          name: "cross_file_darwin",
          dependencies: [],
          resources: [
            .process("Resources")
          ]
      )
    ]
)
