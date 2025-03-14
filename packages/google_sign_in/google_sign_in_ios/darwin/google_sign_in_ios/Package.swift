// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_sign_in_ios",
  platforms: [
    .iOS("12.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "google-sign-in-ios", targets: ["google_sign_in_ios"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS.git",
      from: "7.1.0")
  ],
  targets: [
    .target(
      name: "google_sign_in_ios",
      dependencies: [
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
      ],
      exclude: [
        "include/google_sign_in_ios-umbrella.h", "include/FLTGoogleSignInPlugin.modulemap",
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/google_sign_in_ios")
      ]
    )
  ]
)
