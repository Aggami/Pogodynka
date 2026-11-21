import SharedModels
import Testing
@testable import WeatherService

struct LiveWeatherServiceTests {
    @Test func livePlaceholderReturnsNoCities() async throws {
        let cities = try await LiveWeatherService().searchCities("Kraków")

        #expect(cities.isEmpty)
    }

    @Test func livePlaceholderReturnsZeroDegreeForecast() async throws {
        let city = City(
            id: 1,
            name: "Kraków",
            latitude: 50.06,
            longitude: 19.94,
            country: "Polska",
            region: "małopolskie",
        )
        let forecast = try await LiveWeatherService().forecast(for: city)

        #expect(forecast == Forecast(currentTemperature: 0))
    }
}
