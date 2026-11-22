import Foundation
import SharedModels

public struct UserDefaultsSearchHistoryStore: SearchHistoryStoreProtocol {
    private static let key = "searchHistory"

    private nonisolated(unsafe) let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func loadHistory() async throws -> [City] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return try JSONDecoder().decode([City].self, from: data)
    }

    public func save(_ city: City) async throws {
        var history = try await loadHistory()
        history.removeAll { $0.id == city.id }
        history.insert(city, at: 0)
        try defaults.set(JSONEncoder().encode(history), forKey: Self.key)
    }
}
