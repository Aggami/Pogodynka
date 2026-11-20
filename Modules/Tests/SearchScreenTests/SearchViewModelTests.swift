@testable import SearchScreen
import Testing
import TestSupport

@MainActor
struct SearchViewModelTests {
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
