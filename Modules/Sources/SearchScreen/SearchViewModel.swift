import Foundation
import Observation
import SharedModels
import WeatherService

@MainActor @Observable
final class SearchViewModel {
    private static let minimumSearchLength = 3

    private let weatherService: any WeatherServiceProtocol
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?
    private var lastSearchText = ""

    private(set) var state: SearchState = .idle

    private(set) var query = ""

    init(
        weatherService: any WeatherServiceProtocol = LiveWeatherService(),
        debounce: Duration = .milliseconds(300),
    ) {
        self.weatherService = weatherService
        self.debounce = debounce
    }

    func processQuery(_ text: String) -> String {
        let previousText = trimmed(query)
        query = String(text.filter { $0.isLetter || $0 == " " || $0 == "-" })
        let newText = trimmed(query)
        if newText != previousText {
            startSearch(for: newText)
        }
        return query
    }

    func retry() {
        searchTask?.cancel()
        state = .loading(previous: [])
        runSearch(for: lastSearchText, pause: .zero)
    }

    func waitForSearch() async {
        await searchTask?.value
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespaces)
    }

    private func startSearch(for text: String) {
        searchTask?.cancel()
        searchTask = nil
        guard text.count >= Self.minimumSearchLength else {
            state = .idle
            return
        }
        runSearch(for: text, pause: debounce)
    }

    private func runSearch(for text: String, pause: Duration) {
        lastSearchText = text
        searchTask = Task {
            do {
                try await Task.sleep(for: pause)
                state = .loading(previous: shownCities)
                let cities = try await weatherService.searchCities(text)
                try Task.checkCancellation()
                state = .loaded(cities)
            } catch {
                if !Task.isCancelled {
                    state = .error(error as? WeatherServiceError == .noConnection ? .noConnection : .server)
                }
            }
        }
    }

    private var shownCities: [City] {
        switch state {
        case .idle: []
        case let .loading(previous): previous
        case let .loaded(cities): cities
        case .error: []
        }
    }
}
