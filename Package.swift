// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SNetworkLayer",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SNetworkLayer",
            targets: ["SNetworkLayer"]
        )
    ],
    targets: [
        .target(
            name: "SNetworkLayer",
            path: "SNetworkLayer/Classes"
        ),
        .testTarget(
            name: "SNetworkLayerTests",
            dependencies: ["SNetworkLayer"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
