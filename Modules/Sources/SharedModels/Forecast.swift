import Foundation

public struct Forecast: Sendable, Hashable {
    public let currentTemperature: Double
    public let feelsLikeTemperature: Double
    public let cloudCover: Int
    public let uvIndex: Double
    /// In km/h.
    public let windSpeed: Double
    /// The highest chance of rain or snow for the rest of today.
    public let precipitationChance: Int
    public let condition: WeatherCondition
    public let hours: [HourlyForecast]
    /// The days after today.
    public let days: [DailyForecast]
    public let timeZone: TimeZone

    public init(
        currentTemperature: Double,
        feelsLikeTemperature: Double,
        cloudCover: Int,
        uvIndex: Double,
        windSpeed: Double,
        precipitationChance: Int,
        condition: WeatherCondition,
        hours: [HourlyForecast],
        days: [DailyForecast],
        timeZone: TimeZone,
    ) {
        self.currentTemperature = currentTemperature
        self.feelsLikeTemperature = feelsLikeTemperature
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.windSpeed = windSpeed
        self.precipitationChance = precipitationChance
        self.condition = condition
        self.hours = hours
        self.days = days
        self.timeZone = timeZone
    }
}
