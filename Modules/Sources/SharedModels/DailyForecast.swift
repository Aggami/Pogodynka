import Foundation

public struct DailyForecast: Sendable, Hashable {
    public let date: Date
    public let minTemperature: Double
    public let maxTemperature: Double
    public let condition: WeatherCondition

    public init(date: Date, minTemperature: Double, maxTemperature: Double, condition: WeatherCondition) {
        self.date = date
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.condition = condition
    }
}
