import SearchScreen
import SwiftUI
import WeatherDetailScreen

public struct RootView: View {
    @State private var router = Router()

    public init() {}

    public var body: some View {
        NavigationStack(path: $router.path) {
            SearchView { city in
                router.push(.weatherDetail(city))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .weatherDetail(city):
                    WeatherDetailView(city: city)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
