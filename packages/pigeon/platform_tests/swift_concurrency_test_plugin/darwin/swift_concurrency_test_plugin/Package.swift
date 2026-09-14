// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "swift_concurrency_test_plugin",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "swift-concurrency-test-plugin", targets: ["swift_concurrency_test_plugin"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "swift_concurrency_test_plugin",
      dependencies: [],
      resources: [],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    )
  ]
)
