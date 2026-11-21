public struct City: Codable, Sendable, Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String?
    public let region: String?

    public init(
        id: Int,
        name: String,
        latitude: Double,
        longitude: Double,
        country: String? = nil,
        region: String? = nil,
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.region = region
    }
}
