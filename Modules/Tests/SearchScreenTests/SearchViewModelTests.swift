@testable import SearchScreen
import SharedModels
import Testing
import TestSupport
import WeatherService

enum SearchViewModelTests {
    @MainActor
    struct Validation {
        @Test(arguments: ["Bielsko-Biała", "Nowy Sącz"])
        func validTextIsKept(text: String) {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            let returned = viewModel.processNewTextInput(text)
            #expect(returned == text)
        }

        @Test(arguments: [
            ("Kraków1", "Kraków"),
            ("Łódź!@#_.", "Łódź"),
            ("Nowy Sącz 33-300!", "Nowy Sącz -"),
        ])
        func invalidCharactersAreDropped(typed: String, expected: String) {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            let returned = viewModel.processNewTextInput(typed)
            #expect(returned == expected)
        }

        @Test func newViewModelStartsIdleWithEmptySearchText() {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            #expect(viewModel.state == .idle)
            #expect(viewModel.lastSearchText.isEmpty)
        }

        @Test func typingDoesNotCallTheWeatherService() {
            let service = MockWeatherService()
            let viewModel = SearchViewModel(weatherService: service)
            _ = viewModel.processNewTextInput("Kraków")
            #expect(service.searchedQueries.isEmpty)
        }
    }

    @MainActor
    struct Searching {
        private let wroclaw = City(name: "Wrocław", country: "Polska", region: "dolnośląskie")
        private let wroclawPracze = City(name: "Wrocław Pracze", country: "Polska")

        private func makeViewModel(
            _ service: MockWeatherService,
            debounce: Duration = .zero,
        ) -> SearchViewModel {
            SearchViewModel(weatherService: service, debounce: debounce)
        }

        @Test func searchWithThreeCharactersShowsTheCities() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wro ")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test(arguments: ["", "W", "Wr", "  W ", "   ", "---", "W-r"])
        func shortTextDoesNotSearch(text: String) async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput(text)
            await viewModel.waitForSearch()

            #expect(service.searchedQueries.isEmpty)
            #expect(viewModel.state == .idle)
        }

        @Test func shorteningTheTextGoesBackToIdle() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            _ = viewModel.processNewTextInput("Wr")

            #expect(viewModel.state == .idle)
        }

        @Test func typingTheSameTextAgainAfterShorteningSearchesAgain() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()
            _ = viewModel.processNewTextInput("Wr")
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro", "Wro"])
        }

        @Test func trailingSpaceBelowTheMinimumKeepsIdle() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wr")
            _ = viewModel.processNewTextInput("Wr ")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries.isEmpty)
            #expect(viewModel.state == .idle)
        }

        @Test func changesWithinThePauseMakeOneCall() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service, debounce: .milliseconds(50))

            _ = viewModel.processNewTextInput("Wro")
            _ = viewModel.processNewTextInput("Wroc")
            _ = viewModel.processNewTextInput("Wrocł")
            #expect(service.searchedQueries.isEmpty)
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wrocł"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test func runningSearchIsLoadingAndCarriesPreviousResults() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]), holdsSearches: true)
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wro")
            await service.waitForHeldSearch()
            #expect(viewModel.state == .loading(previous: []))
            service.releaseSearches()
            await viewModel.waitForSearch()
            #expect(viewModel.state == .loaded([wroclaw]))

            _ = viewModel.processNewTextInput("Wroc")
            await service.waitForHeldSearch()
            #expect(viewModel.state == .loading(previous: [wroclaw]))
            service.releaseSearches()
            await viewModel.waitForSearch()
        }

        @Test func newTextCancelsTheRunningSearch() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclawPracze]), holdsSearches: true)
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await service.waitForHeldSearch()

            _ = viewModel.processNewTextInput("Wroc")
            await service.waitForHeldSearch()
            service.releaseSearches()
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro", "Wroc"])
            #expect(viewModel.state == .loaded([wroclawPracze]))
        }

        @Test func cancelledSearchNeverShowsItsAnswer() async {
            let service = MockWeatherService(
                searchResultToReturn: .success([wroclaw]),
                holdsSearches: true,
                ignoresCancellation: true,
            )
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await service.waitForHeldSearch()

            _ = viewModel.processNewTextInput("Wr")
            service.releaseSearches()
            await viewModel.waitForSearch()

            #expect(viewModel.state == .idle)
        }

        @Test func trailingSpaceDoesNotStartANewSearch() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            _ = viewModel.processNewTextInput("Wro ")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test func searchWithNoCitiesEndsInEmptyResult() async {
            let service = MockWeatherService(searchResultToReturn: .success([]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Xyz")
            await viewModel.waitForSearch()

            #expect(viewModel.state == .loaded([]))
        }

        @Test func noConnectionErrorEndsInNoConnectionState() async {
            let service = MockWeatherService(searchResultToReturn: .failure(WeatherServiceError.noConnection))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            #expect(viewModel.state == .error(.noConnection))
        }

        @Test func anyOtherErrorEndsInServerState() async {
            let service = MockWeatherService(searchResultToReturn: .failure(SomeError()))
            let viewModel = makeViewModel(service)

            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            #expect(viewModel.state == .error(.server))
        }

        @Test func searchCancelledByNewTextNeverEndsInError() async {
            let service = MockWeatherService(
                searchResultToReturn: .failure(WeatherServiceError.server),
                holdsSearches: true,
                ignoresCancellation: true,
            )
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await service.waitForHeldSearch()

            _ = viewModel.processNewTextInput("Wr")
            service.releaseSearches()
            await viewModel.waitForSearch()

            #expect(viewModel.state == .idle)
        }

        @Test func retrySearchesTheSameTextAgain() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            viewModel.retry()
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro", "Wro"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test func shorteningTextAfterAnErrorGoesBackToIdle() async {
            let service = MockWeatherService(searchResultToReturn: .failure(WeatherServiceError.server))
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()

            _ = viewModel.processNewTextInput("Wr")

            #expect(viewModel.state == .idle)
        }

        @Test func retryAfterAnErrorShowsLoadingWithNoPreviousResults() async {
            let service = MockWeatherService(searchResultToReturn: .failure(WeatherServiceError.server))
            let viewModel = makeViewModel(service)
            _ = viewModel.processNewTextInput("Wro")
            await viewModel.waitForSearch()
            #expect(viewModel.state == .error(.server))

            viewModel.retry()
            #expect(viewModel.state == .loading(previous: []))
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro", "Wro"])
            #expect(viewModel.state == .error(.server))
        }
    }
}

private struct SomeError: Error {}
