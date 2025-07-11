// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "JSONAPIModel",
    products: [
        .library(
            name: "JSONAPIModel", 
            targets: ["JSONAPIModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git",
                 from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "JSONAPIModel",
            dependencies: ["SwiftyJSON"],
            path: "JSONAPIModel"),
    ]
)
