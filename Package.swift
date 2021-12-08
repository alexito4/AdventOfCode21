// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode21",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/apple/swift-collections.git", .branch("feature/BitSet")),
        .package(url: "https://github.com/devxoul/Then.git", .upToNextMajor(from: "2.7.0")),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", .upToNextMajor(from: "0.3.1")),
        .package(url: "https://github.com/pointfreeco/swift-overture.git", .upToNextMajor(from: "0.5.0")),
        .package(url: "https://github.com/apple/swift-collections-benchmark.git", .upToNextMajor(from: "0.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "AdventOfCode21",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Parsing", package: "swift-parsing"),
                "Then",
                .product(name: "Overture", package: "swift-overture"),
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode21Tests",
            dependencies: ["AdventOfCode21"]
        ),
    ]
)
