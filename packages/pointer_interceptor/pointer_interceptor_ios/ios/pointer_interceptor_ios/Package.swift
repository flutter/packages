// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "pointer_interceptor_ios",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "pointer-interceptor-ios", targets: ["pointer_interceptor_ios"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "pointer_interceptor_ios",
      dependencies: [],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ]
)
