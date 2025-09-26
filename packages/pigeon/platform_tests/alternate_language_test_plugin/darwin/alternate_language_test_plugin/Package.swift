// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "alternate_language_test_plugin",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "alternate-language-test-plugin", targets: ["alternate_language_test_plugin"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "alternate_language_test_plugin",
      dependencies: [],
      resources: [],
      cSettings: [
        .headerSearchPath("include/alternate_language_test_plugin")
      ]
    )
  ]
)
