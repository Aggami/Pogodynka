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

        public func searchCities(_: String) async throws -> [City] {
            switch behavior {
            case .neverAnswers: try await Task.sleep(for: .seconds(3600))
            case .noCities: return []
            case let .failing(error): throw error
            case .instantResults: break
            }
            return [
                City(name: "Wrocław", country: "Polska", region: "dolnośląskie"),
                City(name: "Wrocanka", country: "Polska", region: "podkarpackie"),
                City(name: "Wrocław", country: "Polska"),
            ]
        }

        public func forecast(for _: City) async throws -> Forecast {
            Forecast(currentTemperature: 0)
        }
    }
#endif
