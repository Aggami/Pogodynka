import Foundation

public struct Forecast: Sendable, Hashable {
    public let currentTemperature: Double
    public let cloudCover: Int
    public let precipitationChance: Int
    public let condition: WeatherCondition
    public let hours: [HourlyForecast]
    public let timeZone: TimeZone

    public init(
        currentTemperature: Double,
        cloudCover: Int,
        precipitationChance: Int,
        condition: WeatherCondition,
        hours: [HourlyForecast],
        timeZone: TimeZone,
    ) {
        self.currentTemperature = currentTemperature
        self.cloudCover = cloudCover
        self.precipitationChance = precipitationChance
        self.condition = condition
        self.hours = hours
        self.timeZone = timeZone
    }
}
