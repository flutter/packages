// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "file_selector_macos",
    platforms: [
        .macoOS("10.14")
    ],
    products: [
        // If the plugin name contains "_", replace with "-" for the library name
        .library(name: "file-selector-macos", targets: ["file_selector_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "file_selector_macos",
            dependencies: [],
        )
    ]
)
