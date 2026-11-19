import SearchScreen
import SwiftUI
import WeatherDetailScreen

public struct RootView: View {
    @State private var router = Router()

    public init() {}

    public var body: some View {
        NavigationStack(path: $router.path) {
            SearchView { cityName in
                router.push(.weatherDetail(cityName: cityName))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .weatherDetail(cityName):
                    WeatherDetailView(cityName: cityName)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
