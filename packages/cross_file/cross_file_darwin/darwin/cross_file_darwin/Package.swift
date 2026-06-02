// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "cross_file_darwin",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "cross-file-darwin", targets: ["cross_file_darwin"])
  ],
  dependencies: [],
  targets: [
    .target(
        name: "cross_file_darwin",
        dependencies: [
          "cross_file_darwin_objc"
        ],
        resources: [
          .process("Resources")
        ]
    ),
    .target(
      name: "cross_file_darwin_objc",
      dependencies: [],
      sources: [
        "ffi_bindings.g.m",
      ],
      publicHeadersPath: "include",
    )
  ]
)
