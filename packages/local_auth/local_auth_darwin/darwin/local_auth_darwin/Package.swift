// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "local_auth_darwin",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "local-auth-darwin", targets: ["local_auth_darwin"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "local_auth_darwin",
      dependencies: [],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/local_auth_darwin")
      ]
    )
  ]
)
