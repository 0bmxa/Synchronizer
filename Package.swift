// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Synchronizer",
    products: [
        .library(
            name: "Synchronizer",
            targets: ["Synchronizer"]
        ),
    ],
    targets: [
        .target(
            name: "Synchronizer",
            dependencies: []
        ),
        .testTarget(
            name: "SynchronizerTests",
            dependencies: ["Synchronizer"]
        ),
    ]
)

