import Dependencies

enum SearchHistoryStoreKey: DependencyKey {
    static let liveValue: any SearchHistoryStore = LiveSearchHistoryStore()
}

public extension DependencyValues {
    var searchHistoryStore: any SearchHistoryStore {
        get { self[SearchHistoryStoreKey.self] }
        set { self[SearchHistoryStoreKey.self] = newValue }
    }
}
