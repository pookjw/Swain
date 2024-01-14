// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwainCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SwainCore",
            targets: ["SwainCore"]
        )
    ], 
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-foundation.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SwainCore",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "FoundationPreview", package: "swift-foundation")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SwainCoreTests",
            dependencies: [
                .byName(name: "SwainCore"),
                .product(name: "Testing", package: "swift-testing")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
