import Dependencies

enum WeatherServiceKey: DependencyKey {
    static let liveValue: any WeatherServiceProtocol = LiveWeatherService()
}

public extension DependencyValues {
    var weatherService: any WeatherServiceProtocol {
        get { self[WeatherServiceKey.self] }
        set { self[WeatherServiceKey.self] = newValue }
    }
}
