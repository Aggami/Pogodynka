import DesignSystem
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
            .toolbarRole(.editor)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .weatherDetail(let city):
                    WeatherDetailView(city: city)
                }
            }
        }
        .tint(DesignSystemColor.accent)
    }
}

#Preview {
    RootView()
}
