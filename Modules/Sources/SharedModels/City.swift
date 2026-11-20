public struct City: Sendable, Hashable {
    public let name: String
    public let country: String
    public let region: String?

    public init(name: String, country: String, region: String? = nil) {
        self.name = name
        self.country = country
        self.region = region
    }
}
