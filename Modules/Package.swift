// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "SearchScreen", targets: ["SearchScreen"]),
        .library(name: "WeatherDetailScreen", targets: ["WeatherDetailScreen"]),
    ],
    targets: [
        .target(name: "AppFeature", dependencies: ["SearchScreen", "WeatherDetailScreen"]),
        .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
        .target(name: "SearchScreen"),
        .testTarget(name: "SearchScreenTests", dependencies: ["SearchScreen", "WeatherDetailScreen"]),
        .target(name: "WeatherDetailScreen"),
        .testTarget(name: "WeatherDetailScreenTests", dependencies: ["WeatherDetailScreen"]),
    ],
    swiftLanguageModes: [.v6],
)
