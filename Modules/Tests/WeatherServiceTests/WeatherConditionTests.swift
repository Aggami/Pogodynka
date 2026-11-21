import SharedModels
import Testing
@testable import WeatherService

struct WeatherConditionTests {
    @Test(arguments: [
        (0, WeatherCondition.clear), (1, .partlyCloudy), (2, .partlyCloudy), (3, .cloudy),
        (45, .fog), (48, .fog), (51, .rain), (67, .rain), (80, .rain), (82, .rain),
        (71, .snow), (77, .snow), (85, .snow), (86, .snow), (95, .thunderstorm), (99, .thunderstorm),
        (4, .cloudy), (100, .cloudy),
    ])
    func wmoCodeMapsToCondition(code: Int, expected: WeatherCondition) {
        #expect(WeatherCondition(wmoCode: code) == expected)
    }
}
