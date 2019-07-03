// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GStrobe",
    products: [
        .library(
            name: "GStrobe",
            targets: ["GStrobe"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nixberg/Gimli", .branch("master")),
    ],
    targets: [
        .target(
            name: "GStrobe",
            dependencies: ["Gimli"]),
        .testTarget(
            name: "GStrobeTests",
            dependencies: ["GStrobe"]),
    ]
)
