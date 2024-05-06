// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "file_selector_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "file-selector-ios", targets: ["file_selector_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "file_selector_ios",
            dependencies: [],
            exclude: ["include/cocoapods_file_selector_ios.modulemap"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/file_selector_ios")
            ]
        )
    ]
)
