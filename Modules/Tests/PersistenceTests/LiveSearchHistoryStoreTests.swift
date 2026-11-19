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

        try await store.save(City(name: "Kraków"))

        #expect(try await store.loadHistory().isEmpty)
    }
}
