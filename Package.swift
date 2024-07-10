// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YopakiBIP39",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v12),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "YopakiBIP39",
            targets: ["BIP39"]
        )
    ],
    targets: [
        .target(
            name: "BIP39",
            resources: [
                .copy("Resources/chinese_simplified.txt"),
                .copy("Resources/chinese_traditional.txt"),
                .copy("Resources/czech.txt"),
                .copy("Resources/english.txt"),
                .copy("Resources/french.txt"),
                .copy("Resources/italian.txt"),
                .copy("Resources/japanese.txt"),
                .copy("Resources/korean.txt"),
                .copy("Resources/portuguese.txt"),
                .copy("Resources/russian.txt"),
                .copy("Resources/spanish.txt"),
                .copy("Resources/turkish.txt"),
            ]
        ),
        .testTarget(
            name: "BIP39Tests",
            dependencies: ["BIP39"],
            resources: [
                .copy("Resources/test_JP_BIP39.json"),
                .copy("Resources/vectors.json"),
            ]
        ),
    ]
)
