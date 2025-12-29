// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TenXShared",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TenXShared", targets: ["TenXShared"])
    ],
    targets: [
        .target(name: "TenXShared")
    ]
)
