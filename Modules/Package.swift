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
        .library(name: "TestSupport", targets: ["TestSupport"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: ["SearchScreen", "WeatherDetailScreen", "SharedModels", "DesignSystem"],
        ),
        .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature", "SharedModels"]),
        .target(name: "SearchScreen", dependencies: ["WeatherService", "DesignSystem", "SharedModels"]),
        .testTarget(name: "SearchScreenTests", dependencies: ["SearchScreen", "TestSupport", "SharedModels"]),
        .target(name: "WeatherDetailScreen", dependencies: ["SharedModels", "WeatherService", "DesignSystem"]),
        .testTarget(
            name: "WeatherDetailScreenTests",
            dependencies: ["WeatherDetailScreen", "TestSupport", "SharedModels"],
        ),
        .target(name: "SharedModels"),
        .target(name: "DesignSystem", resources: [.process("Resources")]),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"]),
        .target(
            name: "WeatherService",
            dependencies: ["SharedModels"],
        ),
        .testTarget(
            name: "WeatherServiceTests",
            dependencies: [
                "WeatherService",
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ],
        ),
        .target(
            name: "Persistence",
            dependencies: ["SharedModels"],
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"],
        ),
        .target(
            name: "TestSupport",
            dependencies: [
                "SharedModels",
                "WeatherService",
                "Persistence",
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
