// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Injection",
    platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(name: "Injection", targets: ["Injection"]),
    ],
    targets: [
        .target(name: "Injection", dependencies: [], path: "Sources"),
        .testTarget(name: "InjectionTests", dependencies: ["Injection"], path: "Tests"),
    ]
)
