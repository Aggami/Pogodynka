import Foundation
import SharedModels

public struct OpenMeteoWeatherService: WeatherServiceProtocol {
    private static let searchEndpoint = "https://geocoding-api.open-meteo.com/v1/search"
    private static let forecastEndpoint = "https://api.open-meteo.com/v1/forecast"

    private let session: URLSession
    private let preferredLanguages: [String]

    public init(
        session: URLSession = .shared,
        preferredLanguages: [String] = Locale.preferredLanguages,
    ) {
        self.session = session
        self.preferredLanguages = preferredLanguages
    }

    public func searchCities(_ query: String) async throws(WeatherServiceError) -> [City] {
        guard let url = citySearchURL(for: query) else { throw .server }
        let data = try await fetch(url)
        guard let decoded = try? JSONDecoder().decode(GeocodingResponse.self, from: data) else {
            throw .server
        }
        return (decoded.results ?? []).map(\.city)
    }

    public func forecast(for city: City) async throws(WeatherServiceError) -> Forecast {
        guard let url = forecastURL(for: city) else { throw .server }
        let data = try await fetch(url)
        guard let decoded = try? JSONDecoder().decode(ForecastResponse.self, from: data),
              let forecast = decoded.forecast
        else { throw .server }
        return forecast
    }

    private func fetch(_ url: URL) async throws(WeatherServiceError) -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError {
            throw WeatherServiceError(error)
        } catch is CancellationError {
            throw .cancelled
        } catch {
            throw .server
        }
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw .server
        }
        return data
    }

    private func forecastURL(for city: City) -> URL? {
        URL(string: Self.forecastEndpoint)?.appending(queryItems: [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(
                name: "current",
                value: "temperature_2m,apparent_temperature,cloud_cover,uv_index,wind_speed_10m,weather_code",
            ),
            URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,precipitation_probability_max"),
            URLQueryItem(name: "forecast_hours", value: "12"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "unixtime"),
        ])
    }

    private func citySearchURL(for query: String) -> URL? {
        URL(string: Self.searchEndpoint)?.appending(queryItems: [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: Self.languageCode(from: preferredLanguages)),
            URLQueryItem(name: "format", value: "json"),
        ])
    }

    static func languageCode(from preferredLanguages: [String]) -> String {
        guard let first = preferredLanguages.first,
              let code = first.split(separator: "-").first
        else { return "en" }
        return code.lowercased()
    }
}

private struct GeocodingResponse: Decodable {
    struct Result: Decodable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?

        var city: City {
            City(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                country: country.flatMap { $0.isEmpty ? nil : $0 },
                region: admin1.flatMap { $0.isEmpty ? nil : $0 },
            )
        }
    }

    let results: [Result]?
}

private struct ForecastCurrent: Decodable {
    let time: Double
    let temperature: Double
    let feelsLike: Double
    let cloudCover: Int
    let uvIndex: Double
    let windSpeed: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case feelsLike = "apparent_temperature"
        case cloudCover = "cloud_cover"
        case uvIndex = "uv_index"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
    }
}

private struct ForecastHourly: Decodable {
    let time: [Double]
    let temperature: [Double?]
    let precipitationProbability: [Int?]
    let weatherCode: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
    }
}

private struct ForecastDaily: Decodable {
    let time: [Double]
    let weatherCode: [Int?]
    let maxTemperature: [Double?]
    let precipitationChance: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case maxTemperature = "temperature_2m_max"
        case precipitationChance = "precipitation_probability_max"
    }
}

private struct ForecastResponse: Decodable {
    let timezone: String?
    let utcOffsetSeconds: Int
    let current: ForecastCurrent
    let hourly: ForecastHourly
    let daily: ForecastDaily

    enum CodingKeys: String, CodingKey {
        case timezone
        case utcOffsetSeconds = "utc_offset_seconds"
        case current
        case hourly
        case daily
    }

    var forecast: Forecast? {
        let count = hourly.time.count
        let dayCount = daily.time.count
        guard hourly.temperature.count == count,
              hourly.precipitationProbability.count == count,
              hourly.weatherCode.count == count,
              daily.weatherCode.count == dayCount,
              daily.maxTemperature.count == dayCount,
              daily.precipitationChance.count == dayCount
        else { return nil }
        let hours = (0 ..< count).compactMap { index -> HourlyForecast? in
            guard let temperature = hourly.temperature[index], let code = hourly.weatherCode[index] else { return nil }
            return HourlyForecast(
                time: Date(timeIntervalSince1970: hourly.time[index]),
                temperature: temperature,
                precipitationChance: hourly.precipitationProbability[index] ?? 0,
                condition: WeatherCondition(wmoCode: code),
            )
        }
        let timeZone = timezone.flatMap { TimeZone(identifier: $0) }
            ?? TimeZone(secondsFromGMT: utcOffsetSeconds)
            ?? .gmt
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let now = Date(timeIntervalSince1970: current.time)
        let precipitationToday = hours
            .filter { calendar.isDate($0.time, inSameDayAs: now) }
            .map(\.precipitationChance)
            .max() ?? 0
        let days = (0 ..< dayCount).compactMap { index -> DailyForecast? in
            let date = Date(timeIntervalSince1970: daily.time[index])
            guard !calendar.isDate(date, inSameDayAs: now),
                  let code = daily.weatherCode[index],
                  let maxTemperature = daily.maxTemperature[index]
            else { return nil }
            return DailyForecast(
                date: date,
                maxTemperature: maxTemperature,
                precipitationChance: daily.precipitationChance[index] ?? 0,
                condition: WeatherCondition(wmoCode: code),
            )
        }
        return Forecast(
            currentTemperature: current.temperature,
            feelsLikeTemperature: current.feelsLike,
            cloudCover: current.cloudCover,
            uvIndex: current.uvIndex,
            windSpeed: current.windSpeed,
            precipitationChance: precipitationToday,
            condition: WeatherCondition(wmoCode: current.weatherCode),
            upcomingHoursForecast: hours,
            upcomingDaysForecast: Array(days.prefix(6)),
            timeZone: timeZone,
        )
    }
}
