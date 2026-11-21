import SharedModels
import Testing
@testable import WeatherService

struct LiveWeatherServiceTests {
    @Test func livePlaceholderReturnsNoCities() async throws {
        let cities = try await LiveWeatherService().searchCities("Kraków")

        #expect(cities.isEmpty)
    }

    @Test func livePlaceholderReturnsZeroDegreeForecast() async throws {
        let city = City(name: "Kraków", country: "Polska", region: "małopolskie")
        let forecast = try await LiveWeatherService().forecast(for: city)

        #expect(forecast == Forecast(currentTemperature: 0))
    }
}
