import SharedModels

public struct LiveSearchHistoryStore: SearchHistoryStoreProtocol {
    public init() {}

    public func loadHistory() async throws -> [City] {
        []
    }

    public func save(_: City) async throws {}
}
