import SharedModels

struct LiveWeatherService: WeatherServiceProtocol {
    func searchCities(_: String) async throws -> [City] {
        []
    }

    func forecast(for _: City) async throws -> Forecast {
        Forecast(currentTemperature: 0)
    }
}
