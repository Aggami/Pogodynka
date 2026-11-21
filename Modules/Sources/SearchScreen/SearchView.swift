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
                .padding(.top, 16)
            content
        }
        .background(DesignSystemColor.background)
        .foregroundStyle(DesignSystemColor.text)
        .navigationTitle("Pogodynka")
    }

    private var searchField: some View {
        SearchField(text: $searchFieldText)
            .onChange(of: searchFieldText) { _, newText in
                let filtered = viewModel.processNewTextInput(newText)
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
                .tint(DesignSystemColor.accent)
                .scaleEffect(1.3)
                .padding(.vertical, 20)
            cityList(previous)
        case let .loaded(cities):
            if cities.isEmpty {
                ContentUnavailableView.search(text: viewModel.lastSearchText)
            } else {
                cityList(cities)
            }
        case let .error(error):
            ContentUnavailableView {
                Label(error.title, systemImage: error.systemImage)
            } description: {
                Text(error.message)
            } actions: {
                Button("Try again") { viewModel.retry() }
            }
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
    @MainActor
    private func previewViewModel(_ behavior: PreviewWeatherService.Behavior) -> SearchViewModel {
        let viewModel = SearchViewModel(weatherService: PreviewWeatherService(behavior: behavior), debounce: .zero)
        _ = viewModel.processNewTextInput("Wro")
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

    #Preview("Empty") {
        NavigationStack {
            SearchView(viewModel: previewViewModel(.noCities)) { _ in }
        }
    }

    #Preview("No internet") {
        NavigationStack {
            SearchView(viewModel: previewViewModel(.failing(.noConnection))) { _ in }
        }
    }

    #Preview("API error") {
        NavigationStack {
            SearchView(viewModel: previewViewModel(.failing(.server))) { _ in }
        }
    }
#endif
