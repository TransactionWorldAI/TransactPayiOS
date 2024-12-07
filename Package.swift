// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "TransactPay",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "TransactPay",
            targets: ["TransactPay"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "TransactPay",
            dependencies: [
                "SnapKit"
            ],
            path: "TransactPay"
        ),
        .testTarget(
            name: "TransactPayTests",
            dependencies: ["TransactPay"],
            path: "TransactPayTests"
        ),
    ]
)


