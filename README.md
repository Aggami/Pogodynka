# Pogodynka

A simple iOS weather app.

You search for a city to see its current weather and the forecast for the next hours and days.
It works in Light and Dark Mode, in English and in Polish.

## Weather API

The app uses [Open-Meteo](https://open-meteo.com): its geocoding API for city search and its forecast API for the weather. It's free and needs no API key or account. 
As Open-Meteo's terms ask, the forecast screen credits it as the data source.

## Setup

Requirements:

- Xcode 26 or 27
- iOS 17 or later

Open `Pogodynka.xcworkspace` in Xcode and run the `Pogodynka` scheme on a simulator or a real device. No other setup is needed: the weather API needs no key, and the only package dependency is fetched by Xcode.

## Architecture

- `Pogodynka/` is a thin SwiftUI app target. It only starts the app.
- `Modules/` is a local Swift package with the app's code, split into modules.

The code lives in a package so that modules have clear boundaries and their own tests.

Modules:

- `AppFeature`: the app's root view and navigation between the screens.
- `DesignSystem`: the colour palette for Light and Dark Mode.
- `Persistence`: the search history store, kept in `UserDefaults`.
- `SearchScreen`: city search, search history and their states.
- `SharedModels`: the data types shared by the modules (`City`, `Forecast`, …).
- `TestSupport`: mocks for tests. Only test targets link it, never the app.
- `WeatherDetailScreen`: the forecast details screen and its states.
- `WeatherService`: the Open-Meteo client for city search and forecasts.

## Dependency injection

Dependencies are plain protocols passed in through an `init`. A view model's `init` defaults to the live value, so the app passes nothing. 
Mock implementations are located in `TestSupport` folder.
If the dependency tree grows, or features need global actors or controllable clocks, the next step is [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) (see [`dependency-injection.md`](.ai/context/foundations/dependency-injection.md)).

## Running tests

Tests use Swift Testing and live in the `Modules` package. The `Pogodynka` scheme runs all of
them.

- In Xcode: open `Pogodynka.xcworkspace`, pick the `Pogodynka` scheme and press ⌘U.
- From the command line:

```sh
xcodebuild test -workspace Pogodynka.xcworkspace -scheme Pogodynka -destination 'platform=iOS Simulator,name=iPhone 17'
```

Adding a new test target: declare it with `.testTarget` in `Modules/Package.swift`, then add it to
the `Pogodynka` scheme (Product > Scheme > Edit Scheme > Test > +). Otherwise ⌘U won't run it.

## Development setup

Swift files are formatted and linted by a git pre-commit hook:

```sh
brew install swiftformat swiftlint
git config core.hooksPath scripts/git-hooks
```

## Project process

The app was planned and built ticket by ticket, through GitHub issues and pull requests. The
decisions behind it are in [`.ai/context/foundations/`](.ai/context/foundations/): the PRD, the
roadmap, the weather API research, the design, the project setup and the dependency-injection
approach.
