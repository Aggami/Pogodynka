import Foundation
import SharedModels

public struct OpenMeteoWeatherService: WeatherServiceProtocol {
    private static let searchEndpoint = "https://geocoding-api.open-meteo.com/v1/search"

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
        let url = try buildCitySearchURL(for: query)

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
        guard let decoded = try? JSONDecoder().decode(GeocodingResponse.self, from: data) else {
            throw .server
        }
        return (decoded.results ?? []).map(\.city)
    }

    public func forecast(for _: City) async throws(WeatherServiceError) -> Forecast {
        Forecast(currentTemperature: 0)
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
