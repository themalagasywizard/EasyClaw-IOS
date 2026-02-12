// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyClaw",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "EasyClawCore",
            targets: ["EasyClawCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "EasyClawCore",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/EasyClawCore"),
        .testTarget(
            name: "EasyClawCoreTests",
            dependencies: ["EasyClawCore"]),
    ]
)