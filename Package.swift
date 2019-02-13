// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GStrobe",
    products: [
        .library(
            name: "GStrobe",
            targets: ["GStrobe"]),
    ],
    dependencies: [		
        .package(url: "https://github.com/nixberg/Gimli", from: "0.0.0"),
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
