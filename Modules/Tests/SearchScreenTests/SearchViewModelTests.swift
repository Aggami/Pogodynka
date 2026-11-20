@testable import SearchScreen
import SharedModels
import Testing
import TestSupport

enum SearchViewModelTests {
    @MainActor
    struct Validation {
        @Test(arguments: ["Bielsko-Biała", "Nowy Sącz"])
        func validTextIsKept(text: String) {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            let returned = viewModel.processQuery(text)
            #expect(returned == text)
            #expect(viewModel.query == text)
        }

        @Test(arguments: [
            ("Kraków1", "Kraków"),
            ("Łódź!@#_.", "Łódź"),
            ("Nowy Sącz 33-300!", "Nowy Sącz -"),
        ])
        func invalidCharactersAreDropped(typed: String, expected: String) {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            let returned = viewModel.processQuery(typed)
            #expect(returned == expected)
            #expect(viewModel.query == expected)
        }

        @Test func newViewModelStartsIdleWithEmptyQuery() {
            let viewModel = SearchViewModel(weatherService: MockWeatherService())
            #expect(viewModel.state == .idle)
            #expect(viewModel.query.isEmpty)
        }

        @Test func typingDoesNotCallTheWeatherService() {
            let service = MockWeatherService()
            let viewModel = SearchViewModel(weatherService: service)
            _ = viewModel.processQuery("Kraków")
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

            _ = viewModel.processQuery("Wro ")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test(arguments: ["", "W", "Wr", "  W ", "   "])
        func shortTextDoesNotSearch(text: String) async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processQuery(text)
            await viewModel.waitForSearch()

            #expect(service.searchedQueries.isEmpty)
            #expect(viewModel.state == .idle)
        }

        @Test func shorteningTheTextGoesBackToIdle() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)
            _ = viewModel.processQuery("Wro")
            await viewModel.waitForSearch()

            _ = viewModel.processQuery("Wr")

            #expect(viewModel.state == .idle)
        }

        @Test func changesWithinThePauseMakeOneCall() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)

            _ = viewModel.processQuery("Wro")
            _ = viewModel.processQuery("Wroc")
            _ = viewModel.processQuery("Wrocł")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wrocł"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test func runningSearchIsLoadingAndCarriesPreviousResults() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]), holdsSearches: true)
            let viewModel = makeViewModel(service)

            _ = viewModel.processQuery("Wro")
            await service.waitForHeldSearch()
            #expect(viewModel.state == .loading(previous: []))
            service.releaseSearches()
            await viewModel.waitForSearch()
            #expect(viewModel.state == .loaded([wroclaw]))

            _ = viewModel.processQuery("Wroc")
            await service.waitForHeldSearch()
            #expect(viewModel.state == .loading(previous: [wroclaw]))
            service.releaseSearches()
            await viewModel.waitForSearch()
        }

        @Test func newTextCancelsTheRunningSearch() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclawPracze]), holdsSearches: true)
            let viewModel = makeViewModel(service)
            _ = viewModel.processQuery("Wro")
            await service.waitForHeldSearch()

            _ = viewModel.processQuery("Wroc")
            await service.waitForHeldSearch()
            service.releaseSearches()
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro", "Wroc"])
            #expect(viewModel.state == .loaded([wroclawPracze]))
        }

        @Test func cancelledSearchNeverShowsItsAnswer() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]), holdsSearches: true)
            let viewModel = makeViewModel(service)
            _ = viewModel.processQuery("Wro")
            await service.waitForHeldSearch()

            _ = viewModel.processQuery("Wr")
            await Task.yield()
            service.releaseSearches()

            #expect(viewModel.state == .idle)
        }

        @Test func trailingSpaceDoesNotStartANewSearch() async {
            let service = MockWeatherService(searchResultToReturn: .success([wroclaw]))
            let viewModel = makeViewModel(service)
            _ = viewModel.processQuery("Wro")
            await viewModel.waitForSearch()

            _ = viewModel.processQuery("Wro ")
            await viewModel.waitForSearch()

            #expect(service.searchedQueries == ["Wro"])
            #expect(viewModel.state == .loaded([wroclaw]))
        }

        @Test func serviceErrorGoesBackToIdle() async {
            let service = MockWeatherService(searchResultToReturn: .failure(SomeError()))
            let viewModel = makeViewModel(service)

            _ = viewModel.processQuery("Wro")
            await viewModel.waitForSearch()

            #expect(viewModel.state == .idle)
        }
    }
}

private struct SomeError: Error {}
