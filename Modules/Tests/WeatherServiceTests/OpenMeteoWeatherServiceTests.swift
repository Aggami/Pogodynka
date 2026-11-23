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

    private static func forecastJSON(
        currentTime: Int,
        hours: [(time: Int, chance: Int)],
    ) -> String {
        let times = hours.map(\.time)
        let chances = hours.map { String($0.chance) }.joined(separator: ", ")
        let temperatures = hours.map { _ in "10.0" }.joined(separator: ", ")
        let codes = hours.map { _ in "2" }.joined(separator: ", ")
        return """
        {"utc_offset_seconds": 3600, "timezone": "Europe/Warsaw",
         "current": {"time": \(currentTime), "temperature_2m": 14.5, "apparent_temperature": 12.1, "cloud_cover": 40,
                     "uv_index": 2.6, "wind_speed_10m": 17.6, "weather_code": 2},
         "hourly": {
           "time": \(times),
           "temperature_2m": [\(temperatures)],
           "precipitation_probability": [\(chances)],
           "weather_code": [\(codes)]
         },
         "daily": {
           "time": [1699916400, 1700002800, 1700089200],
           "weather_code": [2, 61, 71],
           "temperature_2m_max": [8.0, 9.5, 1.2],
           "precipitation_probability_max": [20, 70, null]
         }}
        """
    }

    private static let forecastJSON = """
    {"utc_offset_seconds": 3600, "timezone": "Europe/Warsaw",
     "current": {"time": 1700000000, "temperature_2m": 14.5, "apparent_temperature": 12.1, "cloud_cover": 40,
                 "uv_index": 2.6, "wind_speed_10m": 17.6, "weather_code": 2},
     "hourly": {
       "time": [1700000000, 1700003600, 1700007200],
       "temperature_2m": [14.5, 13.0, 12.5],
       "precipitation_probability": [30, 55, null],
       "weather_code": [2, 61, 71]
     },
     "daily": {
       "time": [1699916400, 1700002800, 1700089200],
       "weather_code": [2, 61, 71],
       "temperature_2m_max": [8.0, 9.5, 1.2],
       "precipitation_probability_max": [20, 70, null]
     }}
    """

    @Test func fullResponseBecomesForecast() async throws {
        let service = makeService(json(Self.forecastJSON))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.currentTemperature == 14.5)
        #expect(forecast.feelsLikeTemperature == 12.1)
        #expect(forecast.cloudCover == 40)
        #expect(forecast.uvIndex == 2.6)
        #expect(forecast.windSpeed == 17.6)
        #expect(forecast.condition == .partlyCloudy)
        #expect(forecast.timeZone.identifier == "Europe/Warsaw")
        #expect(forecast.upcomingHoursForecast.map(\.time) == [1_700_000_000, 1_700_003_600, 1_700_007_200]
            .map { Date(timeIntervalSince1970: $0) })
        #expect(forecast.upcomingHoursForecast.map(\.temperature) == [14.5, 13.0, 12.5])
        #expect(forecast.upcomingHoursForecast.map(\.condition) == [.partlyCloudy, .rain, .snow])
        #expect(forecast.upcomingHoursForecast.map(\.precipitationChance) == [30, 55, 0])
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
        let current = items.first { $0.name == "current" }?.value?.split(separator: ",").map(String.init) ?? []
        #expect(current.contains("apparent_temperature"))
        #expect(current.contains("uv_index"))
        #expect(current.contains("wind_speed_10m"))
        let daily = items.first { $0.name == "daily" }?.value?.split(separator: ",").map(String.init) ?? []
        #expect(daily.contains("weather_code"))
        #expect(daily.contains("temperature_2m_max"))
        #expect(daily.contains("precipitation_probability_max"))
        #expect(items.first { $0.name == "forecast_days" }?.value == "7")
        #expect(items.first { $0.name == "hourly" }?.value?.contains("weather_code") == true)
    }

    @Test func laterHourTodayWithHigherChanceSetsTodaysChance() async throws {
        // 2023-11-14 12:06 in Warsaw, so all three hours are still today.
        let now = 1_699_960_000
        let service = makeService(json(Self.forecastJSON(
            currentTime: now,
            hours: [(now, 30), (now + 3600, 55), (now + 7200, 20)],
        )))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.precipitationChance == 55)
    }

    @Test func higherChanceAfterMidnightInCitysTimeZoneIsIgnored() async throws {
        // 21:20 in Warsaw; the hour at 00:20 is already tomorrow.
        let now = 1_699_993_200
        let service = makeService(json(Self.forecastJSON(
            currentTime: now,
            hours: [(now, 30), (now + 3600, 40), (now + 7200, 35), (now + 10800, 90)],
        )))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.precipitationChance == 40)
    }

    @Test func todayFollowsCitysTimeZoneNotUTC() async throws {
        // 23:13 in Warsaw; the next hour, 00:13 Warsaw, is still 23:13 UTC on the same day.
        let now = 1_700_000_000
        let service = makeService(json(Self.forecastJSON(
            currentTime: now,
            hours: [(now, 10), (now + 3600, 80)],
        )))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.precipitationChance == 10)
    }

    @Test(arguments: ["apparent_temperature", "uv_index", "wind_speed_10m"])
    func nullCurrentValueGivesServerError(field: String) async {
        let broken = Self.forecastJSON.replacingOccurrences(
            of: #""\#(field)": "#,
            with: #""\#(field)": null, "ignored": "#,
        )
        let service = makeService(json(broken))

        await #expect(throws: WeatherServiceError.server) {
            try await service.forecast(for: Self.city)
        }
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

extension OpenMeteoWeatherServiceTests {
    @Test func fullResponseGivesTheDaysAfterToday() async throws {
        let service = makeService(json(Self.forecastJSON))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.upcomingDaysForecast == [
            DailyForecast(
                date: Date(timeIntervalSince1970: 1_700_002_800),
                maxTemperature: 9.5,
                precipitationChance: 70,
                condition: .rain,
            ),
            DailyForecast(
                date: Date(timeIntervalSince1970: 1_700_089_200),
                maxTemperature: 1.2,
                precipitationChance: 0,
                condition: .snow,
            ),
        ])
    }

    @Test func dayWithMissingValueIsLeftOut() async throws {
        let broken = Self.forecastJSON.replacingOccurrences(
            of: "[8.0, 9.5, 1.2]",
            with: "[8.0, null, 1.2]",
        )
        let service = makeService(json(broken))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.upcomingDaysForecast.map(\.maxTemperature) == [1.2])
    }

    @Test func dailyArraysOfDifferentLengthsGiveServerError() async {
        let broken = Self.forecastJSON.replacingOccurrences(
            of: "[2.0, 3.5, -3.1]",
            with: "[2.0, 3.5]",
        )
        let service = makeService(json(broken))

        await #expect(throws: WeatherServiceError.server) {
            try await service.forecast(for: Self.city)
        }
    }

    @Test func forecastHasAtMostSixDays() async throws {
        let days = (0 ..< 9).map { 1_700_002_800 + $0 * 86400 }
        let values = days.map { _ in "5.0" }.joined(separator: ", ")
        let codes = days.map { _ in "2" }.joined(separator: ", ")
        let chances = days.map { _ in "10" }.joined(separator: ", ")
        let json = Self.forecastJSON(currentTime: 1_700_000_000, hours: [(1_700_000_000, 10)])
            .replacingOccurrences(
                of: #""daily": \{[^}]*\}"#,
                with: """
                "daily": {"time": \(days), "weather_code": [\(codes)],
                  "temperature_2m_max": [\(values)], "precipitation_probability_max": [\(chances)]}
                """,
                options: .regularExpression,
            )
        let service = makeService(self.json(json))

        let forecast = try await service.forecast(for: Self.city)

        #expect(forecast.upcomingDaysForecast.count == 6)
    }
}
