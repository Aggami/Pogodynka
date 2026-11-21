import Foundation

public struct HourlyForecast: Sendable, Hashable {
    public let time: Date
    public let temperature: Double
    public let precipitationChance: Int
    public let condition: WeatherCondition

    public init(time: Date, temperature: Double, precipitationChance: Int, condition: WeatherCondition) {
        self.time = time
        self.temperature = temperature
        self.precipitationChance = precipitationChance
        self.condition = condition
    }
}
