import ConcurrencyExtras
import Persistence
import SharedModels

public final class MockSearchHistoryStore: SearchHistoryStoreProtocol {
    private let loadError: (any Error)?
    private let saveError: (any Error)?
    private let storedHistory: LockIsolated<[City]>
    private let saved = LockIsolated<[City]>([])

    public init(
        history: [City] = [],
        loadError: (any Error)? = nil,
        saveError: (any Error)? = nil,
    ) {
        storedHistory = LockIsolated(history)
        self.loadError = loadError
        self.saveError = saveError
    }

    public var savedCities: [City] {
        saved.value
    }

    public func loadHistory() async throws -> [City] {
        if let loadError { throw loadError }
        return storedHistory.value
    }

    public func save(_ city: City) async throws {
        saved.withValue { $0.append(city) }
        if let saveError { throw saveError }
        storedHistory.withValue { $0.append(city) }
    }
}
