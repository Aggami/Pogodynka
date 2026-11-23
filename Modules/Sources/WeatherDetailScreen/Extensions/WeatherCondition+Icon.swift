import DesignSystem
import SharedModels
import SwiftUI

extension WeatherCondition {
    var icon: WeatherIconData {
        let sun = DesignSystemColor.sun
        let cloud = DesignSystemColor.cloud
        let precipitation = DesignSystemColor.precipitation
        return switch self {
        case .clear:
            WeatherIconData(symbolName: "sun.max.fill", mainColor: sun, secondaryColor: sun, tertiaryColor: sun)
        case .partlyCloudy:
            WeatherIconData(symbolName: "cloud.sun.fill", mainColor: cloud, secondaryColor: sun, tertiaryColor: sun)
        case .cloudy:
            WeatherIconData(symbolName: "cloud.fill", mainColor: cloud, secondaryColor: cloud, tertiaryColor: cloud)
        case .fog:
            WeatherIconData(symbolName: "cloud.fog.fill", mainColor: cloud, secondaryColor: cloud, tertiaryColor: cloud)
        case .rain:
            WeatherIconData(
                symbolName: "cloud.rain.fill",
                mainColor: cloud,
                secondaryColor: precipitation,
                tertiaryColor: precipitation,
            )
        case .snow:
            WeatherIconData(
                symbolName: "cloud.snow.fill",
                mainColor: cloud,
                secondaryColor: DesignSystemColor.snow,
                tertiaryColor: DesignSystemColor.snow,
            )
        case .thunderstorm:
            WeatherIconData(
                symbolName: "cloud.bolt.rain.fill",
                mainColor: cloud,
                secondaryColor: precipitation,
                tertiaryColor: sun,
            )
        }
    }

    var displayName: String {
        switch self {
        case .clear: String(localized: "Clear", bundle: .module)
        case .partlyCloudy: String(localized: "Partly cloudy", bundle: .module)
        case .cloudy: String(localized: "Cloudy", bundle: .module)
        case .fog: String(localized: "Fog", bundle: .module)
        case .rain: String(localized: "Rain", bundle: .module)
        case .snow: String(localized: "Snow", bundle: .module)
        case .thunderstorm: String(localized: "Thunderstorm", bundle: .module)
        }
    }
}
