// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "test_plugin",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "test-plugin", targets: ["test_plugin"])
  ],
  dependencies: [],
  // #docregion spm-targets
  targets: [
    .target(
      name: "test_plugin_objc_gen",
      dependencies: [],
      publicHeadersPath: "."
    ),
    .target(
      name: "test_plugin",
      dependencies: ["test_plugin_objc_gen"]
    ),
  ]
  // #enddocregion spm-targets
)
