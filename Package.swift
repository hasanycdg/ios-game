// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RegiereDeutschland",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "RegiereDeutschlandCore",
            targets: ["RegiereDeutschlandCore"]
        )
    ],
    targets: [
        .target(
            name: "RegiereDeutschlandCore",
            resources: [
                .process("Data/Events"),
                .process("Data/News")
            ]
        ),
        .testTarget(
            name: "RegiereDeutschlandCoreTests",
            dependencies: ["RegiereDeutschlandCore"]
        )
    ]
)
