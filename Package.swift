// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RawInputStabilizer",
    products: [
        .library(
            name: "RawInputStabilizer",
            targets: ["RawInputStabilizer"]),
    ],
    targets: [
        .target(
            name: "RawInputStabilizer",
            dependencies: []),
        .testTarget(
            name: "RawInputStabilizerTests",
            dependencies: ["RawInputStabilizer"]),
    ]
)
