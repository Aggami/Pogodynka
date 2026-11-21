import Foundation

public enum WeatherServiceError: Error, Equatable {
    case noConnection
    case server
    case cancelled
}

extension WeatherServiceError {
    init(_ error: URLError) {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
             .cannotConnectToHost, .timedOut, .dataNotAllowed:
            self = .noConnection
        case .cancelled:
            self = .cancelled
        default:
            self = .server
        }
    }
}
