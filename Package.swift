// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let packageName = "SwiftyRate"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v9)],
    products: [.library(name: packageName, targets: [packageName])],
    targets: [.target(name: packageName, path: "Sources")],
    swiftLanguageVersions: [.v5]
)
