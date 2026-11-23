import Foundation
import SharedModels

extension Forecast {
    static let placeholder: Forecast = {
        let start = Date(timeIntervalSince1970: 1_795_276_800)
        let hours = (0 ..< 12).map { index in
            HourlyForecast(
                time: start.addingTimeInterval(Double(index) * 3600),
                temperature: 14,
                precipitationChance: 30,
                condition: .partlyCloudy,
            )
        }
        let days = (1 ... 6).map { index in
            DailyForecast(
                date: start.addingTimeInterval(Double(index) * 86400),
                minTemperature: 4,
                maxTemperature: 12,
                condition: .partlyCloudy,
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
            days: days,
            currentTime: start,
            timeZone: .gmt,
        )
    }()
}
