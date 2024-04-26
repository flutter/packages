// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "image_picker_ios",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "image-picker-ios", targets: ["image_picker_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "image_picker_ios",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/image_picker_ios")
            ]
        )
    ]
)
