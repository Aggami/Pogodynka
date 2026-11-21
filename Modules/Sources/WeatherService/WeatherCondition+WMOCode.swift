import SharedModels

extension WeatherCondition {
    init(wmoCode: Int) {
        switch wmoCode {
        case 0: self = .clear
        case 1 ... 2: self = .partlyCloudy
        case 3: self = .cloudy
        case 45, 48: self = .fog
        case 51 ... 67, 80 ... 82: self = .rain
        case 71 ... 77, 85 ... 86: self = .snow
        case 95 ... 99: self = .thunderstorm
        default: self = .cloudy
        }
    }
}
