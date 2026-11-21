import Observation
import SharedModels
import WeatherService

@MainActor @Observable
final class WeatherDetailViewModel {
    let city: City
    private(set) var state: ForecastState = .loading

    private let weatherService: any WeatherServiceProtocol

    init(city: City, weatherService: any WeatherServiceProtocol = OpenMeteoWeatherService()) {
        self.city = city
        self.weatherService = weatherService
    }

    func load() async {
        do {
            let forecast = try await weatherService.forecast(for: city)
            try Task.checkCancellation()
            state = .loaded(forecast)
        } catch {
            if !Task.isCancelled, error as? WeatherServiceError != .cancelled {
                state = .error(error as? WeatherServiceError == .noConnection ? .noConnection : .server)
            }
        }
    }

    func retry() async {
        state = .loading
        await load()
    }
}
