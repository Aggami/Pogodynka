// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    targets: [
        .target(name: "AppFeature"),
        .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
    ],
    swiftLanguageModes: [.v6],
)
