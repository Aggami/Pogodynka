import SwiftUI

public struct WeatherDetailView: View {
    private let cityName: String

    public init(cityName: String) {
        self.cityName = cityName
    }

    public var body: some View {
        Text(cityName)
            .font(.largeTitle)
    }
}

#Preview {
    WeatherDetailView(cityName: "Kraków")
}
