// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "test_plugin",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "test-plugin", targets: ["test_plugin"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "test_plugin",
            dependencies: [],
            resources: []
        )
    ]
)
