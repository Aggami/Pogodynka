import SharedModels

public protocol SearchHistoryStore: Sendable {
    func loadHistory() async throws -> [City]
    func save(_ city: City) async throws
}
