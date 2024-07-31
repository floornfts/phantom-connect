// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhantomConnect",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        .library(
            name: "PhantomConnect",
            targets: ["PhantomConnect"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/floornfts/Solana.Swift.git",
            revision: "958603ac10dac9b25adcbf0200b750faac791456"
        )
    ],
    targets: [
        .target(
            name: "PhantomConnect",
            dependencies: [
                .product(
                    name: "Solana",
                    package: "Solana.Swift"
                )
            ],
            exclude: ["PhantomConnectExample", "Assets"]
        ),
        .testTarget(
            name: "PhantomConnectTests",
            dependencies: [
                "PhantomConnect"
            ],
            exclude: ["PhantomConnectExample", "Assets"]
        ),
    ]
)
