enum SearchError: Equatable {
    case noConnection
    case server

    var title: String {
        switch self {
        case .noConnection: String(localized: "No internet connection", bundle: .module)
        case .server: String(localized: "Something went wrong", bundle: .module)
        }
    }

    var message: String {
        switch self {
        case .noConnection: String(localized: "Check your connection and try again.", bundle: .module)
        case .server: String(localized: "We couldn't load cities. Please try again.", bundle: .module)
        }
    }

    var systemImage: String {
        switch self {
        case .noConnection: "wifi.slash"
        case .server: "exclamationmark.triangle"
        }
    }
}
