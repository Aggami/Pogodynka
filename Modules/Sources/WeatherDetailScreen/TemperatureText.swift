enum TemperatureText {
    static func text(_ temperature: Double) -> String {
        "\(Int(temperature.rounded()))°"
    }
}
