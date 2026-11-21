import Testing
@testable import WeatherDetailScreen

struct DoubleDisplayedTemperatureTests {
    @Test func temperatureIsRoundedToWholeDegrees() {
        #expect(14.6.displayedTemperature == "15°")
    }

    @Test func temperatureJustBelowZeroShowsZero() {
        #expect((-0.4).displayedTemperature == "0°")
    }
}
