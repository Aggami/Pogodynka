import SharedModels

public struct LiveWeatherService: WeatherServiceProtocol {
    public init() {}

    public func searchCities(_: String) async throws -> [City] {
        []
    }

    public func forecast(for _: City) async throws -> Forecast {
        Forecast(currentTemperature: 0)
    }
}
