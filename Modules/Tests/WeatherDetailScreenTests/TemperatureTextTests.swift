import Testing
@testable import WeatherDetailScreen

struct TemperatureTextTests {
    @Test func temperatureIsRoundedToWholeDegrees() {
        #expect(TemperatureText.text(14.6) == "15°")
    }

    @Test func temperatureJustBelowZeroShowsZero() {
        #expect(TemperatureText.text(-0.4) == "0°")
    }
}
