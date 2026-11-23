#if DEBUG
    import Foundation
    import SharedModels

    public extension Forecast {
        static let sample: Forecast = {
            let conditions: [WeatherCondition] = [
                .partlyCloudy, .partlyCloudy, .cloudy, .rain, .rain, .thunderstorm,
                .cloudy, .fog, .clear, .clear, .partlyCloudy, .snow,
            ]
            let start = Date(timeIntervalSince1970: 1_795_276_800)
            let hours = conditions.enumerated().map { index, condition in
                HourlyForecast(
                    time: start.addingTimeInterval(Double(index) * 3600),
                    temperature: 14 - Double(index) * 0.7,
                    precipitationChance: condition == .rain ? 60 : (index * 5) % 40,
                    condition: condition,
                )
            }
            return Forecast(
                currentTemperature: 14,
                feelsLikeTemperature: 12,
                cloudCover: 40,
                uvIndex: 3,
                windSpeed: 18,
                precipitationChance: 30,
                condition: .partlyCloudy,
                hours: hours,
                timeZone: TimeZone(identifier: "Europe/Warsaw") ?? .gmt,
            )
        }()
    }
#endif
