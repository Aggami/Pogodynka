import SharedModels

public struct LiveSearchHistoryStore: SearchHistoryStore {
    public init() {}

    public func loadHistory() async throws -> [City] {
        []
    }

    public func save(_: City) async throws {}
}
