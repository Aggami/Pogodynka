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
        let data = try await fetch(buildCitySearchURL(for: query))
        guard let decoded = try? JSONDecoder().decode(GeocodingResponse.self, from: data) else {
            throw .server
        }
        return (decoded.results ?? []).map(\.city)
    }

    public func forecast(for city: City) async throws(WeatherServiceError) -> Forecast {
        let data = try await fetch(buildForecastURL(for: city))
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

    private func buildForecastURL(for city: City) throws(WeatherServiceError) -> URL {
        var components = URLComponents(string: Self.forecastEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,cloud_cover,weather_code"),
            URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weather_code"),
            URLQueryItem(name: "forecast_hours", value: "12"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "unixtime"),
        ]
        guard let url = components?.url else { throw .server }
        return url
    }

    private func buildCitySearchURL(for query: String) throws(WeatherServiceError) -> URL {
        var components = URLComponents(string: Self.searchEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: Self.languageCode(from: preferredLanguages)),
            URLQueryItem(name: "format", value: "json"),
        ]
        guard let url = components?.url else { throw .server }
        return url
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
    let temperature: Double
    let cloudCover: Int
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case cloudCover = "cloud_cover"
        case weatherCode = "weather_code"
    }
}

private struct ForecastHourly: Decodable {
    let time: [Double]
    let temperature: [Double]
    let precipitationProbability: [Int?]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
    }
}

private struct ForecastResponse: Decodable {
    let timezone: String?
    let utcOffsetSeconds: Int
    let current: ForecastCurrent
    let hourly: ForecastHourly

    enum CodingKeys: String, CodingKey {
        case timezone
        case utcOffsetSeconds = "utc_offset_seconds"
        case current
        case hourly
    }

    var forecast: Forecast? {
        let count = hourly.time.count
        guard hourly.temperature.count == count,
              hourly.precipitationProbability.count == count,
              hourly.weatherCode.count == count
        else { return nil }
        let hours = (0 ..< count).map { index in
            HourlyForecast(
                time: Date(timeIntervalSince1970: hourly.time[index]),
                temperature: hourly.temperature[index],
                precipitationChance: hourly.precipitationProbability[index] ?? 0,
                condition: WeatherCondition(wmoCode: hourly.weatherCode[index]),
            )
        }
        let timeZone = timezone.flatMap { TimeZone(identifier: $0) }
            ?? TimeZone(secondsFromGMT: utcOffsetSeconds)
            ?? .gmt
        return Forecast(
            currentTemperature: current.temperature,
            cloudCover: current.cloudCover,
            precipitationChance: hours.first?.precipitationChance ?? 0,
            condition: WeatherCondition(wmoCode: current.weatherCode),
            hours: hours,
            timeZone: timeZone,
        )
    }
}
