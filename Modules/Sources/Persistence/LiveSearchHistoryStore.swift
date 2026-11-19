import SharedModels

struct LiveSearchHistoryStore: SearchHistoryStore {
    func loadHistory() async throws -> [City] {
        []
    }

    func save(_: City) async throws {}
}
