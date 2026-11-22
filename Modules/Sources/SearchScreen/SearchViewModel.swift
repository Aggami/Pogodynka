import Foundation
import Observation
import Persistence
import SharedModels
import WeatherService

@MainActor @Observable
final class SearchViewModel {
    private static let minimumSearchLength = 3

    private(set) var state: SearchState = .idle
    private(set) var lastSearchText = ""
    private(set) var history: [City] = []
    private(set) var showsHistory = true
    private var searchTask: Task<Void, Never>?
    private var historySaveTask: Task<Void, Never>?
    private var hasLoadedHistory = false

    private let debounce: Duration
    private let weatherService: any WeatherServiceProtocol
    private let historyStore: any SearchHistoryStoreProtocol

    init(
        weatherService: any WeatherServiceProtocol = OpenMeteoWeatherService(),
        historyStore: any SearchHistoryStoreProtocol = UserDefaultsSearchHistoryStore(),
        debounce: Duration = .milliseconds(300),
    ) {
        self.weatherService = weatherService
        self.historyStore = historyStore
        self.debounce = debounce
    }

    func loadHistory() async {
        guard !hasLoadedHistory else { return }
        hasLoadedHistory = true
        history = await (try? historyStore.loadHistory()) ?? []
    }

    func selectCity(_ city: City) {
        history.removeAll { $0.id == city.id }
        history.insert(city, at: 0)
        let previousSave = historySaveTask
        historySaveTask = Task {
            await previousSave?.value
            try? await historyStore.save(city)
        }
    }

    func waitForHistorySave() async {
        await historySaveTask?.value
    }

    func processNewTextInput(_ inputText: String) -> String {
        showsHistory = inputText.isEmpty
        let filteredText = String(inputText.filter { $0.isLetter || $0 == " " || $0 == "-" })
        let processedText = filteredText.trimmingCharacters(in: .whitespaces)
        if processedText.filter(\.isLetter).count < Self.minimumSearchLength {
            resetSearch()
        } else if processedText != lastSearchText {
            startSearch(for: processedText)
        }
        return filteredText
    }

    func retry() {
        searchTask?.cancel()
        state = .loading(previous: [])
        runSearch(for: lastSearchText, pause: .zero)
    }

    func waitForSearch() async {
        await searchTask?.value
    }

    private func resetSearch() {
        searchTask?.cancel()
        lastSearchText = ""
        state = .idle
    }

    private func startSearch(for text: String) {
        searchTask?.cancel()
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
