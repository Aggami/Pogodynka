# Pogodynka

A simple iOS weather app.

## Setup and architecture

Requirements:

- Xcode 26 or 27
- iOS 17 or later

Open `Pogodynka.xcworkspace` in Xcode and run the `Pogodynka` scheme on a simulator/real device.

Main app layout:

- `Pogodynka/` is a thin SwiftUI app target. It only starts the app.
- `Modules/` is a local Swift package with the app's code, split into modules. The `TestSupport` module holds mocks and is linked only by test targets.

The code lives in a package so that modules have clear boundaries and their own tests. See [Development setup](#development-setup) before committing.

## Dependency injection

Dependencies are injected with [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).
App-wide services (weather, persistence) are protocols, read in code as
`@Dependency(\.weatherService)`. Small, stateless tools are just passed in through an `init`. The live values are
placeholders for now. Tests override them with the mocks from `TestSupport`, for example
`@Test(.dependency(\.weatherService, MockWeatherService()))`.

## Development setup

Swift files are formatted and linted by a git pre-commit hook:

```sh
brew install swiftformat swiftlint
git config core.hooksPath scripts/git-hooks
```
