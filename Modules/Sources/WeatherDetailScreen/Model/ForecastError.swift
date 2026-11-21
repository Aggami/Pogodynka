enum ForecastError: Equatable {
    case noConnection
    case server

    var title: String {
        switch self {
        case .noConnection: "No internet connection"
        case .server: "Something went wrong"
        }
    }

    var message: String {
        switch self {
        case .noConnection: "Check your connection and try again."
        case .server: "We couldn't load the forecast. Please try again."
        }
    }

    var systemImage: String {
        switch self {
        case .noConnection: "wifi.slash"
        case .server: "exclamationmark.triangle"
        }
    }
}
