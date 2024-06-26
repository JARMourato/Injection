// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Injection",
    platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1)],
    products: [
        .library(name: "Injection", targets: ["Injection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
    ],
    targets: [
        .macro(
            name: "InjectionMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(name: "Injection", dependencies: ["InjectionMacros"]),

        .testTarget(
            name: "InjectionTests",
            dependencies: [
                "Injection",
                "InjectionMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests"
        ),
    ]
)
