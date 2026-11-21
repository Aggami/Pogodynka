import SharedModels
import SwiftUI

public struct WeatherDetailView: View {
    private let city: City

    public init(city: City) {
        self.city = city
    }

    public var body: some View {
        Text(city.name)
            .font(.largeTitle)
    }
}

#Preview {
    WeatherDetailView(city: City(
        id: 1,
        name: "Kraków",
        latitude: 50.06,
        longitude: 19.94,
        country: "Polska",
        region: "małopolskie",
    ))
}
