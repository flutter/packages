// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "url_launcher_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "url-launcher-ios", targets: ["url_launcher_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "url_launcher_ios",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
