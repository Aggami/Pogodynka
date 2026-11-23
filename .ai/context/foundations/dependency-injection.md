# Dependency injection

## Approach

Plain **constructor injection** with **protocol-based** dependencies. A type that needs the weather
service or the search history takes it in its `init` as `any WeatherServiceProtocol` /
`any SearchHistoryStoreProtocol`. The app root creates the live values (`OpenMeteoWeatherService()`,
`UserDefaultsSearchHistoryStore()`) once and passes them down.

Update (2026-11-20): a view model's `init` parameter defaults to the live value
(`weatherService: any WeatherServiceProtocol = OpenMeteoWeatherService()`), so the app uses it without
passing anything, and previews and tests inject a mock.

Why this way:

- The services are stateless clients, so nothing needs to be global.
- A type's dependencies are visible in its `init`.
- Each test builds its own model with its own mock, so parallel tests (Swift Testing) share nothing.
- No third-party DI library. swift-dependencies was tried first and dropped (changed 2026-11-19):
  it hides dependencies behind `@Dependency` and adds several packages for little gain at this size.
  Revisit it if the tree gets deep or features need controllable clocks.

## Testing module

`TestSupport` holds the mocks (`MockWeatherService`, `MockSearchHistoryStore`). Only test targets
link it, never the app.

## Adding a new dependency

1. Protocol (`Sendable`) in its module, with `public` methods.
2. Live implementation: `public struct` with a `public init()`. Live types may be named after their
   provider (`OpenMeteoWeatherService`).
3. Mock in `TestSupport`: a `final class` that stubs results or errors and records calls. Keep
   recorded state in `LockIsolated` (ConcurrencyExtras), because the protocol is `Sendable`.
4. Features take the protocol in their `init`, defaulting to the live value; previews and tests pass a mock.

## Using a mock in a test

```swift
let krakow = City(id: 1, name: "Kraków", latitude: 50.06, longitude: 19.94, country: "Polska", region: "małopolskie")
let service = MockWeatherService(searchResultToReturn: .success([krakow]))
let viewModel = SearchViewModel(weatherService: service, historyStore: MockSearchHistoryStore())
// ... act, assert on the view model, then on service.searchedQueries / requestedCities
```

For the history store, read `savedCities` on `MockSearchHistoryStore`.
