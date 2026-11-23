import Testing
@testable import WeatherDetailScreen

struct DoubleDisplayedWeatherValuesTests {
    @Test func uvIndexIsRoundedToWholeNumber() {
        #expect(2.6.displayedUVIndex == "3")
    }

    @Test func windSpeedIsRoundedAndShowsUnit() {
        #expect(17.6.displayedWindSpeed == "18 km/h")
    }
}
