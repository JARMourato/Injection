// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Injection",
    platforms: [
        .iOS(.v11), .macOS(.v10_13), .tvOS(.v11), .watchOS(.v4),
    ],
    products: [
        .library(name: "Injection", targets: ["Injection"]),
    ],
    targets: [
        .target(name: "Injection", dependencies: [], path: "Sources"),
        .testTarget(name: "InjectionTests", dependencies: ["Injection"], path: "Tests"),
    ]
)
