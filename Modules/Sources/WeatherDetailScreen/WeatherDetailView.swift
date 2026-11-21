import DesignSystem
import SharedModels
import SwiftUI
import WeatherService

public struct WeatherDetailView: View {
    @State private var viewModel: WeatherDetailViewModel

    public init(city: City) {
        self.init(viewModel: WeatherDetailViewModel(city: city))
    }

    init(viewModel: WeatherDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            content
                .padding(.horizontal)
        }
        .background(DesignSystemColor.background)
        .foregroundStyle(DesignSystemColor.text)
        .navigationTitle(viewModel.city.name)
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            CurrentWeatherBar(forecast: .placeholder)
                .redacted(reason: .placeholder)
        case let .loaded(forecast):
            CurrentWeatherBar(forecast: forecast)
        case let .error(error):
            ContentUnavailableView {
                Label(error.title, systemImage: error.systemImage)
            } description: {
                Text(error.message)
            } actions: {
                Button("Try again") { Task { await viewModel.retry() } }
            }
        }
    }
}

#if DEBUG
    @MainActor
    private func previewView(_ behavior: PreviewWeatherService.Behavior) -> some View {
        NavigationStack {
            WeatherDetailView(viewModel: WeatherDetailViewModel(
                city: City(id: 1, name: "Kraków", latitude: 50.06, longitude: 19.94, country: "Polska"),
                weatherService: PreviewWeatherService(behavior: behavior),
            ))
        }
    }

    #Preview("Loading") { previewView(.neverAnswers) }
    #Preview("Loaded") { previewView(.instantResults) }
    #Preview("No internet") { previewView(.failing(.noConnection)) }
    #Preview("API error") { previewView(.failing(.server)) }
#endif
