#if DEBUG
    import SharedModels

    public struct PreviewWeatherService: WeatherServiceProtocol {
        public enum Behavior: Sendable {
            case instantResults
            case neverAnswers
            case noCities
            case failing(WeatherServiceError)
        }

        public let behavior: Behavior

        public init(behavior: Behavior) {
            self.behavior = behavior
        }

        public func searchCities(_: String) async throws(WeatherServiceError) -> [City] {
            switch behavior {
            case .neverAnswers:
                do { try await Task.sleep(for: .seconds(3600)) } catch { throw .cancelled }
            case .noCities: return []
            case let .failing(error): throw error
            case .instantResults: break
            }
            return [
                City(
                    id: 1,
                    name: "Wrocław",
                    latitude: 51.1,
                    longitude: 17.03,
                    country: "Polska",
                    region: "dolnośląskie",
                ),
                City(
                    id: 2,
                    name: "Wrocanka",
                    latitude: 49.7,
                    longitude: 21.7,
                    country: "Polska",
                    region: "podkarpackie",
                ),
                City(id: 3, name: "Wrocław", latitude: 51.0, longitude: 17.0, country: "Polska"),
            ]
        }

        public func forecast(for _: City) async throws(WeatherServiceError) -> Forecast {
            switch behavior {
            case .neverAnswers:
                do { try await Task.sleep(for: .seconds(3600)) } catch { throw .cancelled }
            case let .failing(error): throw error
            case .instantResults, .noCities: break
            }
            return .sample
        }
    }
#endif
