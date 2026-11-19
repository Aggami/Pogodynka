import SharedModels

public protocol WeatherServiceProtocol: Sendable {
    func searchCities(_ query: String) async throws -> [City]
    func forecast(for city: City) async throws -> Forecast
}
