import DesignSystem
import SharedModels
import SwiftUI
import WeatherService

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var searchFieldText = ""
    private let onCitySelected: (City) -> Void

    public init(onCitySelected: @escaping (City) -> Void) {
        self.init(viewModel: SearchViewModel(), onCitySelected: onCitySelected)
    }

    init(viewModel: SearchViewModel, onCitySelected: @escaping (City) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCitySelected = onCitySelected
    }

    public var body: some View {
        VStack {
            searchField
                .padding(.horizontal)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemColor.background)
        .foregroundStyle(DesignSystemColor.text)
        .navigationTitle("Pogodynka")
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystemColor.secondaryText)
                .accessibilityHidden(true)
            TextField(
                "",
                text: $searchFieldText,
                prompt: Text("Start searching a city").foregroundStyle(DesignSystemColor.secondaryText),
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .accessibilityLabel("Search for a city")
            if !searchFieldText.isEmpty {
                Button {
                    searchFieldText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignSystemColor.secondaryText)
                }
                .accessibilityLabel("Clear text")
            }
        }
        .padding(10)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 10))
        .onChange(of: searchFieldText) { _, newText in
            let filtered = viewModel.processQuery(newText)
            if filtered != newText {
                searchFieldText = filtered
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Spacer()
        case let .loading(previous):
            ProgressView()
                .padding(.top, 8)
            cityList(previous)
        case let .loaded(cities):
            cityList(cities)
        }
    }

    private func cityList(_ cities: [City]) -> some View {
        List(cities, id: \.self) { city in
            Button {
                onCitySelected(city)
            } label: {
                CityRow(city: city)
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(DesignSystemColor.divider)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
    private struct PreviewWeatherService: WeatherServiceProtocol {
        enum Behavior {
            case instantResults
            case neverAnswers
        }

        let behavior: Behavior

        func searchCities(_: String) async throws -> [City] {
            if behavior == .neverAnswers {
                try await Task.sleep(for: .seconds(3600))
            }
            return [
                City(name: "Wrocław", country: "Polska", region: "dolnośląskie"),
                City(name: "Wrocanka", country: "Polska", region: "podkarpackie"),
                City(name: "Wrocław", country: "Polska"),
            ]
        }

        func forecast(for _: City) async throws -> Forecast {
            Forecast(currentTemperature: 0)
        }
    }

    @MainActor
    private func previewViewModel(_ behavior: PreviewWeatherService.Behavior) -> SearchViewModel {
        let viewModel = SearchViewModel(weatherService: PreviewWeatherService(behavior: behavior), debounce: .zero)
        _ = viewModel.processQuery("Wro")
        return viewModel
    }

    #Preview("Idle") {
        NavigationStack {
            SearchView(viewModel: SearchViewModel(
                weatherService: PreviewWeatherService(behavior: .instantResults),
            )) { _ in
            }
        }
    }

    #Preview("Loading") {
        NavigationStack {
            SearchView(viewModel: previewViewModel(.neverAnswers)) { _ in }
        }
    }

    #Preview("Results") {
        NavigationStack {
            SearchView(viewModel: previewViewModel(.instantResults)) { _ in }
        }
    }
#endif
