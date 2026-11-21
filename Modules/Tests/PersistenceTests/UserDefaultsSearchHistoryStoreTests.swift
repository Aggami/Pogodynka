import Foundation
@testable import Persistence
import SharedModels
import Testing

struct UserDefaultsSearchHistoryStoreTests {
    private let suiteName = "UserDefaultsSearchHistoryStoreTests-\(UUID().uuidString)"

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: suiteName))
    }

    private func city(_ id: Int) -> City {
        City(id: id, name: "City \(id)", latitude: Double(id), longitude: Double(id) + 0.5)
    }

    @Test func newStoreReturnsEmptyHistory() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(try await UserDefaultsSearchHistoryStore(defaults: defaults).loadHistory().isEmpty)
    }

    @Test func savedCityComesBackWithAllFields() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsSearchHistoryStore(defaults: defaults)
        let kraków = City(
            id: 1,
            name: "Kraków",
            latitude: 50.06,
            longitude: 19.94,
            country: "Polska",
            region: "małopolskie",
        )

        try await store.save(kraków)

        #expect(try await store.loadHistory() == [kraków])
    }

    @Test func citiesComeBackNewestFirst() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsSearchHistoryStore(defaults: defaults)

        try await store.save(city(1))
        try await store.save(city(2))
        try await store.save(city(3))

        #expect(try await store.loadHistory().map(\.id) == [3, 2, 1])
    }

    @Test func savingExistingCityMovesItToTopWithoutDuplicate() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsSearchHistoryStore(defaults: defaults)

        try await store.save(city(1))
        try await store.save(city(2))
        try await store.save(city(1))

        #expect(try await store.loadHistory().map(\.id) == [1, 2])
    }

    @Test func newStoreOnSameDefaultsKeepsHistory() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        try await UserDefaultsSearchHistoryStore(defaults: defaults).save(city(1))

        #expect(try await UserDefaultsSearchHistoryStore(defaults: defaults).loadHistory().map(\.id) == [1])
    }

    @Test func manyCitiesAreAllKept() async throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsSearchHistoryStore(defaults: defaults)

        for id in 1 ... 50 {
            try await store.save(city(id))
        }

        #expect(try await store.loadHistory().count == 50)
    }
}
