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
        ),
        .executable(
            name: "RegiereDeutschland",
            targets: ["RegiereDeutschlandApp"]
        )
    ],
    targets: [
        .target(
            name: "RegiereDeutschlandCore",
            resources: [
                .process("Data/Events")
            ]
        ),
        .executableTarget(
            name: "RegiereDeutschlandApp",
            dependencies: ["RegiereDeutschlandCore"]
        ),
        .testTarget(
            name: "RegiereDeutschlandCoreTests",
            dependencies: ["RegiereDeutschlandCore"]
        )
    ]
)
