import Testing
@testable import WeatherDetailScreen

struct DisplayedTemperatureTests {
    @Test func temperatureIsRoundedToWholeDegrees() {
        #expect(14.6.displayedTemperature == "15°")
    }

    @Test func temperatureJustBelowZeroShowsZero() {
        #expect((-0.4).displayedTemperature == "0°")
    }
}
