// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "file_selector_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        // If the plugin name contains "_", replace with "-" for the library name
        .library(name: "file-selector-ios", targets: ["file_selector_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "file_selector_ios",
            dependencies: [],
            exclude: ["include/file_selector_ios.modulemap"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/file_selector_ios")
            ]
        )
    ]
)
