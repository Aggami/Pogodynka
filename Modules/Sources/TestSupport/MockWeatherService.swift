import ConcurrencyExtras
import SharedModels
import WeatherService

public final class MockWeatherService: WeatherServiceProtocol {
    private let searchResultToReturn: Result<[City], any Error>
    private let forecastResultToReturn: Result<Forecast, any Error>
    private let searched = LockIsolated<[String]>([])
    private let requested = LockIsolated<[City]>([])

    public init(
        searchResultToReturn: Result<[City], any Error> = .success([]),
        forecastResultToReturn: Result<Forecast, any Error> = .success(Forecast(currentTemperature: 0)),
    ) {
        self.searchResultToReturn = searchResultToReturn
        self.forecastResultToReturn = forecastResultToReturn
    }

    public var searchedQueries: [String] {
        searched.value
    }

    public var requestedCities: [City] {
        requested.value
    }

    public func searchCities(_ query: String) async throws -> [City] {
        searched.withValue { $0.append(query) }
        return try searchResultToReturn.get()
    }

    public func forecast(for city: City) async throws -> Forecast {
        requested.withValue { $0.append(city) }
        return try forecastResultToReturn.get()
    }
}
