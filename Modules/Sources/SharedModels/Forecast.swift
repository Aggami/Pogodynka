import Foundation

public struct Forecast: Sendable, Hashable {
    public let currentTemperature: Double
    public let feelsLikeTemperature: Double
    public let cloudCover: Int
    public let uvIndex: Double
    public let windSpeed: Double
    public let precipitationChance: Int // highest chance of rain or snow for the rest of today
    public let condition: WeatherCondition
    public let upcomingHoursForecast: [HourlyForecast]
    public let upcomingDaysForecast: [DailyForecast]
    public let timeZone: TimeZone

    public init(
        currentTemperature: Double,
        feelsLikeTemperature: Double,
        cloudCover: Int,
        uvIndex: Double,
        windSpeed: Double,
        precipitationChance: Int,
        condition: WeatherCondition,
        upcomingHoursForecast: [HourlyForecast],
        upcomingDaysForecast: [DailyForecast],
        timeZone: TimeZone,
    ) {
        self.currentTemperature = currentTemperature
        self.feelsLikeTemperature = feelsLikeTemperature
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.windSpeed = windSpeed
        self.precipitationChance = precipitationChance
        self.condition = condition
        self.upcomingHoursForecast = upcomingHoursForecast
        self.upcomingDaysForecast = upcomingDaysForecast
        self.timeZone = timeZone
    }
}
