// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUtilities",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Utilities",
            targets: ["Utilities"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
        .package(url: "https://github.com/stefanspringer1/AutoreleasepoolShim", from: "1.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "AutoreleasepoolShim",
            ]
        ),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"]),
    ]
)
