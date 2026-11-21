import SharedModels
import Testing
import TestSupport
@testable import WeatherDetailScreen
import WeatherService

@MainActor
struct WeatherDetailViewModelTests {
    private let city = City(id: 1, name: "Kraków", latitude: 50.06, longitude: 19.94, country: "Polska")

    @Test func newScreenIsLoading() {
        let viewModel = WeatherDetailViewModel(city: city, weatherService: MockWeatherService())
        #expect(viewModel.state == .loading)
    }

    @Test func loadingAsksForThisCitysForecastAndShowsIt() async {
        let service = MockWeatherService(forecastResultToReturn: .success(.sample))
        let viewModel = WeatherDetailViewModel(city: city, weatherService: service)
        await viewModel.load()
        #expect(service.requestedCities == [city])
        #expect(viewModel.state == .loaded(.sample))
    }

    @Test func serverFailureShowsApiError() async {
        let service = MockWeatherService(forecastResultToReturn: .failure(.server))
        let viewModel = WeatherDetailViewModel(city: city, weatherService: service)
        await viewModel.load()
        #expect(viewModel.state == .error(.server))
    }

    @Test func noConnectionShowsNoInternet() async {
        let service = MockWeatherService(forecastResultToReturn: .failure(.noConnection))
        let viewModel = WeatherDetailViewModel(city: city, weatherService: service)
        await viewModel.load()
        #expect(viewModel.state == .error(.noConnection))
    }

    @Test func cancelledLoadShowsNoError() async {
        let service = MockWeatherService(forecastResultToReturn: .failure(.cancelled))
        let viewModel = WeatherDetailViewModel(city: city, weatherService: service)
        await viewModel.load()
        #expect(viewModel.state == .loading)
    }

    @Test func tryAgainAsksAgainAndShowsTheResult() async {
        let service = MockWeatherService(forecastResultToReturn: .failure(.server))
        let viewModel = WeatherDetailViewModel(city: city, weatherService: service)
        await viewModel.load()
        service.setForecastResult(.success(.sample))
        await viewModel.retry()
        #expect(service.requestedCities.count == 2)
        #expect(viewModel.state == .loaded(.sample))
    }
}
