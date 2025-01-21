// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "in_app_purchase_storekit",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "in-app-purchase-storekit", targets: ["in_app_purchase_storekit"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "in_app_purchase_storekit",
      dependencies: [
        "storekit_objc"
      ],
      resources: [
        .process("Resources/PrivacyInfo.xcprivacy")
      ]
    ),
    .target(
      name: "storekit_objc",
      dependencies: [],
      cSettings: [
        .headerSearchPath("include/storekit_objc")
      ]
    ),
  ]
)
