import Foundation
import SharedModels

extension Forecast {
    static let placeholder = Forecast(
        currentTemperature: 14,
        cloudCover: 40,
        precipitationChance: 30,
        condition: .partlyCloudy,
        hours: [],
        timeZone: .current,
    )
}
