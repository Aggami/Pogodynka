import Observation
import WeatherService

@MainActor @Observable
final class SearchViewModel {
    private let weatherService: any WeatherServiceProtocol

    private(set) var state: SearchState = .idle

    private(set) var query = ""

    init(weatherService: any WeatherServiceProtocol = LiveWeatherService()) {
        self.weatherService = weatherService
    }

    func processQuery(_ text: String) -> String {
        query = String(text.filter { $0.isLetter || $0 == " " || $0 == "-" })
        return query
    }
}
