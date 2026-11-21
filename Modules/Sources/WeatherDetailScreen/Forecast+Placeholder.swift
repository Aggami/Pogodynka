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
        return Forecast(
            currentTemperature: 14,
            cloudCover: 40,
            precipitationChance: 30,
            condition: .partlyCloudy,
            hours: hours,
            timeZone: .gmt,
        )
    }()
}
