import DesignSystem
import Persistence
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
        .task { await viewModel.loadHistory() }
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
            idleContent
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

    @ViewBuilder
    private var idleContent: some View {
        if !viewModel.showsHistory {
            Spacer()
        } else if viewModel.history.isEmpty {
            ContentUnavailableView(
                "What is the weather like?",
                systemImage: "magnifyingglass",
                description: Text("Start searching for a city around the world to see the weather forecast."),
            )
        } else {
            cityList(viewModel.history, header: "Latest searches")
        }
    }

    private func cityList(_ cities: [City], header: LocalizedStringKey? = nil) -> some View {
        List {
            Section {
                ForEach(cities) { city in
                    Button {
                        viewModel.selectCity(city)
                        searchFieldText = ""
                        onCitySelected(city)
                    } label: {
                        CityRow(city: city)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(DesignSystemColor.divider)
                }
            } header: {
                if let header {
                    Label(header, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystemColor.secondaryText)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
    @MainActor
    private func previewViewModel(_ behavior: PreviewWeatherService.Behavior) -> SearchViewModel {
        let viewModel = SearchViewModel(
            weatherService: PreviewWeatherService(behavior: behavior),
            historyStore: PreviewSearchHistoryStore(hasHistory: false),
            debounce: .zero,
        )
        _ = viewModel.processNewTextInput("Wro")
        return viewModel
    }

    #Preview("Idle with history") {
        NavigationStack {
            SearchView(viewModel: SearchViewModel(
                weatherService: PreviewWeatherService(behavior: .instantResults),
                historyStore: PreviewSearchHistoryStore(hasHistory: true),
            )) { _ in
            }
        }
    }

    #Preview("Idle, no history") {
        NavigationStack {
            SearchView(viewModel: SearchViewModel(
                weatherService: PreviewWeatherService(behavior: .instantResults),
                historyStore: PreviewSearchHistoryStore(hasHistory: false),
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
