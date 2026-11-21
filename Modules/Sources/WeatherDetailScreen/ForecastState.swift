import SharedModels

enum ForecastState: Equatable {
    case loading
    case loaded(Forecast)
    case error(ForecastError)
}
