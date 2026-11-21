@testable import Persistence
import SharedModels
import Testing

struct LiveSearchHistoryStoreTests {
    @Test func livePlaceholderReturnsEmptyHistory() async throws {
        let history = try await LiveSearchHistoryStore().loadHistory()

        #expect(history.isEmpty)
    }

    @Test func livePlaceholderSaveDoesNotThrowAndHistoryStaysEmpty() async throws {
        let store = LiveSearchHistoryStore()

        try await store.save(City(
            id: 1,
            name: "Kraków",
            latitude: 50.06,
            longitude: 19.94,
            country: "Polska",
            region: "małopolskie",
        ))

        #expect(try await store.loadHistory().isEmpty)
    }
}
