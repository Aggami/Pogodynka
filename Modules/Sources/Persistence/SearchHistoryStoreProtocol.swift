import SharedModels

public protocol SearchHistoryStoreProtocol: Sendable {
    func loadHistory() async throws -> [City]
    func save(_ city: City) async throws
}
