// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftUsing",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50000.0")),
        .package(url: "https://github.com/hartbit/Yaap.git", .branch("master")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "swiftusing",
            dependencies: ["SwiftUsingCore", "Yaap"]),
        .target(
            name: "SwiftUsingCore",
            dependencies: ["SwiftSyntax"]),
        .testTarget(
            name: "SwiftUsingTests",
            dependencies: ["SwiftUsingCore", "SnapshotTesting"])
    ]
)
