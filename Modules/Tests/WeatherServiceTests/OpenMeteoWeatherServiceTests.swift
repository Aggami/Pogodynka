import Foundation
import SharedModels
import Testing
@testable import WeatherService

@Suite(.serialized)
struct OpenMeteoWeatherServiceTests {
    private func makeService(
        _ stub: URLProtocolStub.Stub,
        preferredLanguages: [String] = ["pl-PL"],
    ) -> OpenMeteoWeatherService {
        URLProtocolStub.reset(stub: stub)
        return OpenMeteoWeatherService(session: URLProtocolStub.makeSession(), preferredLanguages: preferredLanguages)
    }

    private func json(_ text: String, status: Int = 200) -> URLProtocolStub.Stub {
        .response(status: status, data: Data(text.utf8))
    }

    @Test func resultsBecomeCities() async throws {
        let service = makeService(json("""
        {"results": [
          {"id": 1, "name": "Wrocław", "latitude": 51.1, "longitude": 17.03,
           "country": "Polska", "admin1": "dolnośląskie"},
          {"id": 2, "name": "Wrocanka", "latitude": 49.7, "longitude": 21.7,
           "country": "Polska", "admin1": "podkarpackie"}
        ]}
        """))

        let cities = try await service.searchCities("Wroc")

        #expect(cities == [
            City(id: 1, name: "Wrocław", latitude: 51.1, longitude: 17.03, country: "Polska", region: "dolnośląskie"),
            City(id: 2, name: "Wrocanka", latitude: 49.7, longitude: 21.7, country: "Polska", region: "podkarpackie"),
        ])
    }

    @Test func requestSendsNameCountAndLanguage() async throws {
        let service = makeService(json("{}"))

        _ = try await service.searchCities("Nowy Sącz")

        let url = try #require(URLProtocolStub.requests.first?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.first { $0.name == "name" }?.value == "Nowy Sącz")
        #expect(items.first { $0.name == "count" }?.value == "10")
        #expect(items.first { $0.name == "language" }?.value == "pl")
    }

    @Test func missingResultsGiveEmptyList() async throws {
        let service = makeService(json(#"{"generationtime_ms": 0.5}"#))

        let cities = try await service.searchCities("xqzv")

        #expect(cities.isEmpty)
    }

    @Test func resultWithoutCountryOrRegionHasNeither() async throws {
        let service =
            makeService(json(#"{"results": [{"id": 3, "name": "Nowhere", "latitude": 1.0, "longitude": 2.0}]}"#))

        let cities = try await service.searchCities("Nowhere")

        #expect(cities.first?.country == nil)
        #expect(cities.first?.region == nil)
    }

    @Test(arguments: [URLError.Code.notConnectedToInternet, .timedOut])
    func offlineErrorsGiveNoConnection(code: URLError.Code) async {
        let service = makeService(.failure(URLError(code)))

        await #expect(throws: WeatherServiceError.noConnection) {
            try await service.searchCities("Kraków")
        }
    }

    @Test(arguments: [
        URLProtocolStub.Stub.response(status: 400, data: Data("{}".utf8)),
        .response(status: 200, data: Data("not json".utf8)),
        .failure(URLError(.badServerResponse)),
    ])
    func otherFailuresGiveServerError(stub: URLProtocolStub.Stub) async {
        let service = makeService(stub)

        await #expect(throws: WeatherServiceError.server) {
            try await service.searchCities("Kraków")
        }
    }

    private static let city = City(
        id: 1,
        name: "Kraków",
        latitude: 50.06,
        longitude: 19.94,
        country: "Polska",
        region: "małopolskie",
    )

    private static let forecastJSON = """
    {"utc_offset_seconds": 3600, "timezone": "Europe/Warsaw",
     "current": {"time": 1700000000, "temperature_2m": 14.5, "cloud_cover": 40, "weather_code": 2},
     "hourly": {
       "time": [1700000000, 1700003600, 1700007200],
       "temperature_2m": [14.5, 13.0, 12.5],
       "precipitation_probability": [30, 55, null],
       "weather_code": [2, 61, 71]
     }}
    """

    @Test func fullResponseBecomesForecast() async throws {
        let service = makeService(json(Self.forecastJSON))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.currentTemperature == 14.5)
        #expect(forecast.cloudCover == 40)
        #expect(forecast.condition == .partlyCloudy)
        #expect(forecast.timeZone.identifier == "Europe/Warsaw")
        #expect(forecast.hours.map(\.time) == [1_700_000_000, 1_700_003_600, 1_700_007_200]
            .map { Date(timeIntervalSince1970: $0) })
        #expect(forecast.hours.map(\.temperature) == [14.5, 13.0, 12.5])
        #expect(forecast.hours.map(\.condition) == [.partlyCloudy, .rain, .snow])
        #expect(forecast.hours.map(\.precipitationChance) == [30, 55, 0])
    }

    @Test func forecastRequestSendsLocationHoursAndFields() async throws {
        let service = makeService(json(Self.forecastJSON))

        _ = try await service.forecast(for: Self.city)

        let url = try #require(URLProtocolStub.requests.first?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.first { $0.name == "latitude" }?.value == "50.06")
        #expect(items.first { $0.name == "longitude" }?.value == "19.94")
        #expect(items.first { $0.name == "forecast_hours" }?.value == "12")
        #expect(items.first { $0.name == "timezone" }?.value == "auto")
        #expect(items.first { $0.name == "current" }?.value?.contains("weather_code") == true)
        #expect(items.first { $0.name == "hourly" }?.value?.contains("weather_code") == true)
    }

    @Test func chanceOfRainIsTheCurrentHoursValue() async throws {
        let service = makeService(json(Self.forecastJSON))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.precipitationChance == 30)
    }

    @Test(arguments: [
        URLProtocolStub.Stub.response(status: 500, data: Data(forecastJSON.utf8)),
        .response(status: 200, data: Data("not json".utf8)),
    ])
    func forecastFailuresGiveServerError(stub: URLProtocolStub.Stub) async {
        let service = makeService(stub)

        await #expect(throws: WeatherServiceError.server) {
            try await service.forecast(for: Self.city)
        }
    }

    @Test func forecastWithoutConnectionGivesNoConnection() async {
        let service = makeService(.failure(URLError(.notConnectedToInternet)))

        await #expect(throws: WeatherServiceError.noConnection) {
            try await service.forecast(for: Self.city)
        }
    }

    @Test(arguments: [(["pl-PL", "fr"], "pl"), (["en"], "en"), (["DE-at"], "de"), ([], "en")])
    func languageIsTakenFromFirstPreferredLanguage(preferred: [String], expected: String) async throws {
        let service = makeService(json("{}"), preferredLanguages: preferred)

        _ = try await service.searchCities("Wroc")

        let url = try #require(URLProtocolStub.requests.first?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.first { $0.name == "language" }?.value == expected)
    }

    @Test func cancelledRequestGivesCancelled() async {
        let service = makeService(.failure(URLError(.cancelled)))

        await #expect(throws: WeatherServiceError.cancelled) {
            try await service.searchCities("Kraków")
        }
    }
}
