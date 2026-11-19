// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "SearchScreen", targets: ["SearchScreen"]),
        .library(name: "WeatherDetailScreen", targets: ["WeatherDetailScreen"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "WeatherService", targets: ["WeatherService"]),
        .library(name: "Persistence", targets: ["Persistence"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.17.2"),
    ],
    targets: [
        .target(name: "AppFeature", dependencies: ["SearchScreen", "WeatherDetailScreen"]),
        .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
        .target(name: "SearchScreen"),
        .testTarget(name: "SearchScreenTests", dependencies: ["SearchScreen"]),
        .target(name: "WeatherDetailScreen"),
        .testTarget(name: "WeatherDetailScreenTests", dependencies: ["WeatherDetailScreen"]),
        .target(name: "SharedModels"),
        .target(
            name: "WeatherService",
            dependencies: [
                "SharedModels",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .testTarget(
            name: "WeatherServiceTests",
            dependencies: ["WeatherService"],
        ),
        .target(
            name: "Persistence",
            dependencies: [
                "SharedModels",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"],
        ),
    ],
    swiftLanguageModes: [.v6],
)
