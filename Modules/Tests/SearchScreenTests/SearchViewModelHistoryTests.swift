@testable import SearchScreen
import SharedModels
import Testing
import TestSupport
import WeatherService

extension SearchViewModelTests {
    @MainActor
    struct History {
        private let wroclaw = City(id: 1, name: "Wrocław", latitude: 51.1, longitude: 17.03)
        private let krakow = City(id: 2, name: "Kraków", latitude: 50.06, longitude: 19.94)
        private let tokyo = City(id: 3, name: "Tokyo", latitude: 35.69, longitude: 139.69)

        private func makeViewModel(_ store: MockSearchHistoryStore) -> SearchViewModel {
            SearchViewModel(weatherService: MockWeatherService(), historyStore: store, debounce: .zero)
        }

        @Test func loadingShowsTheStoredCitiesNewestFirst() async {
            let viewModel = makeViewModel(MockSearchHistoryStore(history: [krakow, wroclaw]))

            await viewModel.loadHistory()

            #expect(viewModel.history == [krakow, wroclaw])
        }

        @Test func failedLoadShowsEmptyHistoryAndNoError() async {
            let viewModel = makeViewModel(MockSearchHistoryStore(loadError: WeatherServiceError.server))

            await viewModel.loadHistory()

            #expect(viewModel.history.isEmpty)
            #expect(viewModel.state == .idle)
        }

        @Test func selectingACitySavesItToTheStore() async {
            let store = MockSearchHistoryStore()
            let viewModel = makeViewModel(store)

            viewModel.selectCity(tokyo)
            await viewModel.waitForHistorySave()

            #expect(store.savedCities == [tokyo])
        }

        @Test func selectingACityAlreadyInHistoryMovesItToTheTop() async {
            let viewModel = makeViewModel(MockSearchHistoryStore(history: [krakow, wroclaw]))
            await viewModel.loadHistory()

            viewModel.selectCity(wroclaw)
            await viewModel.waitForHistorySave()

            #expect(viewModel.history == [wroclaw, krakow])
        }

        @Test func historyShowsWhenNothingIsTypedHidesAfterOneLetterAndShowsAgainWhenCleared() {
            let viewModel = makeViewModel(MockSearchHistoryStore())
            #expect(viewModel.showsHistory)

            _ = viewModel.processNewTextInput("W")
            #expect(!viewModel.showsHistory)

            _ = viewModel.processNewTextInput("")
            #expect(viewModel.showsHistory)
        }

        @Test func loadingAgainAfterSelectingACityKeepsItAtTheTop() async {
            let viewModel = makeViewModel(MockSearchHistoryStore(history: [krakow, wroclaw]))
            await viewModel.loadHistory()

            viewModel.selectCity(wroclaw)
            await viewModel.loadHistory()
            await viewModel.waitForHistorySave()

            #expect(viewModel.history == [wroclaw, krakow])
        }

        @Test func clearingTheTextAfterResultsGoesBackToIdleWithThePickedCityOnTop() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = SearchViewModel(
                weatherService: service,
                historyStore: MockSearchHistoryStore(history: [krakow]),
                debounce: .zero,
            )
            await viewModel.loadHistory()
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()
            #expect(viewModel.state == .loaded([wroclaw]))

            viewModel.selectCity(wroclaw)
            _ = viewModel.processNewTextInput("")
            await viewModel.waitForHistorySave()

            #expect(viewModel.state == .idle)
            #expect(viewModel.showsHistory)
            #expect(viewModel.history == [wroclaw, krakow])
        }
    }
}
