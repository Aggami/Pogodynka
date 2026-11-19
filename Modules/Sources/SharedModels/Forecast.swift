public struct Forecast: Sendable, Hashable {
    public let currentTemperature: Double

    public init(currentTemperature: Double) {
        self.currentTemperature = currentTemperature
    }
}
