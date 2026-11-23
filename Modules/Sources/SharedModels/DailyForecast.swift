import Foundation

public struct DailyForecast: Sendable, Hashable {
    public let date: Date
    public let maxTemperature: Double
    public let precipitationChance: Int
    public let condition: WeatherCondition

    public init(date: Date, maxTemperature: Double, precipitationChance: Int, condition: WeatherCondition) {
        self.date = date
        self.maxTemperature = maxTemperature
        self.precipitationChance = precipitationChance
        self.condition = condition
    }
}
