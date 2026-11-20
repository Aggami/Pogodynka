import DesignSystem
import SharedModels
import SwiftUI
import WeatherService

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var searchFieldText = ""
    private let onCitySelected: (String) -> Void

    public init(onCitySelected: @escaping (String) -> Void) {
        self.init(viewModel: SearchViewModel(), onCitySelected: onCitySelected)
    }

    init(viewModel: SearchViewModel, onCitySelected: @escaping (String) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCitySelected = onCitySelected
    }

    public var body: some View {
        VStack {
            searchField
                .padding(.horizontal)
            content
            Button("Show sample city") {
                onCitySelected("Kraków")
            }
            Spacer()
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
            EmptyView()
        }
    }
}

#if DEBUG
    private struct PreviewWeatherService: WeatherServiceProtocol {
        func searchCities(_: String) async throws -> [City] {
            []
        }

        func forecast(for _: City) async throws -> Forecast {
            Forecast(currentTemperature: 0)
        }
    }

    #Preview("Idle, Light") {
        NavigationStack {
            SearchView(viewModel: SearchViewModel(weatherService: PreviewWeatherService())) { _ in }
        }
        .preferredColorScheme(.light)
    }

    #Preview("Idle, Dark") {
        NavigationStack {
            SearchView(viewModel: SearchViewModel(weatherService: PreviewWeatherService())) { _ in }
        }
        .preferredColorScheme(.dark)
    }
#endif
