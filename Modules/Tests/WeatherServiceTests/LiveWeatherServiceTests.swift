import SharedModels
import Testing
@testable import WeatherService

struct LiveWeatherServiceTests {
    @Test func livePlaceholderReturnsNoCities() async throws {
        let cities = try await LiveWeatherService().searchCities("Kraków")

        #expect(cities.isEmpty)
    }

    @Test func livePlaceholderReturnsZeroDegreeForecast() async throws {
        let forecast = try await LiveWeatherService().forecast(for: City(name: "Kraków"))

        #expect(forecast == Forecast(currentTemperature: 0))
    }
}
