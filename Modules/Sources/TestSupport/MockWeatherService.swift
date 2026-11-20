import ConcurrencyExtras
import SharedModels
import WeatherService

public final class MockWeatherService: WeatherServiceProtocol {
    private let searchResultToReturn: Result<[City], any Error>
    private let forecastResultToReturn: Result<Forecast, any Error>
    private let holdsSearches: Bool
    private let searched = LockIsolated<[String]>([])
    private let requested = LockIsolated<[City]>([])
    private let heldSearches = LockIsolated<[UInt: CheckedContinuation<Void, any Error>]>([:])
    private let nextHeldID = LockIsolated<UInt>(0)

    public init(
        searchResultToReturn: Result<[City], any Error> = .success([]),
        forecastResultToReturn: Result<Forecast, any Error> = .success(Forecast(currentTemperature: 0)),
        holdsSearches: Bool = false,
    ) {
        self.searchResultToReturn = searchResultToReturn
        self.forecastResultToReturn = forecastResultToReturn
        self.holdsSearches = holdsSearches
    }

    public var searchedQueries: [String] {
        searched.value
    }

    public var requestedCities: [City] {
        requested.value
    }

    public func searchCities(_ query: String) async throws -> [City] {
        searched.withValue { $0.append(query) }
        if holdsSearches { try await waitForRelease() }
        return try searchResultToReturn.get()
    }

    public func forecast(for city: City) async throws -> Forecast {
        requested.withValue { $0.append(city) }
        return try forecastResultToReturn.get()
    }

    /// Suspends until a held search is waiting for `releaseSearches()`.
    public func waitForHeldSearch() async {
        while heldSearches.value.isEmpty {
            await Task.yield()
        }
    }

    /// Lets every search that is currently held return its answer.
    public func releaseSearches() {
        let continuations = heldSearches.withValue { held in
            defer { held = [:] }
            return Array(held.values)
        }
        for continuation in continuations {
            continuation.resume()
        }
    }

    private func waitForRelease() async throws {
        let id = nextHeldID.withValue { id in
            defer { id += 1 }
            return id
        }
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                heldSearches.withValue { $0[id] = continuation }
                if Task.isCancelled { cancelHeldSearch(id) }
            }
        } onCancel: {
            cancelHeldSearch(id)
        }
    }

    private func cancelHeldSearch(_ id: UInt) {
        heldSearches.withValue { $0.removeValue(forKey: id) }?.resume(throwing: CancellationError())
    }
}
