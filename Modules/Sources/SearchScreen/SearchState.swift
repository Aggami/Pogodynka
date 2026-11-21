import SharedModels

enum SearchState: Equatable {
    case idle
    case loading(previous: [City])
    case loaded([City])
    case error(SearchError)
}
