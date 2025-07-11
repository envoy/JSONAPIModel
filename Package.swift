// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "JSONAPIModel",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "JSONAPIModel",
            targets: ["JSONAPIModel"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "JSONAPIModel",
            dependencies: ["SwiftyJSON"],
            path: "JSONAPIModel",
            exclude: ["Info.plist"]),
        .testTarget(
          name: "JSONAPIModelTests",
          dependencies: ["JSONAPIModel"],
          path: "JSONAPIModelTests",
          resources: [
            .copy("Fixtures/payload.json"),
            .copy("Fixtures/device-config.json"),
          ])
    ]
)
