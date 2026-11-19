# Pogodynka

A simple iOS weather app.

## Setup and architecture

Requirements:

- Xcode 26 or 27
- iOS 17 or later

Open `Pogodynka.xcworkspace` in Xcode and run the `Pogodynka` scheme on a simulator/real device.

Main app layout:

- `Pogodynka/` is a thin SwiftUI app target. It only starts the app.
- `Modules/` is a local Swift package with the app's code, split into modules. It currently holds one module, `AppFeature`, with the root view.

The code lives in a package so that modules have clear boundaries and their own tests. See [Development setup](#development-setup) before committing.

## Development setup

Swift files are formatted and linted by a git pre-commit hook:

```sh
brew install swiftformat swiftlint
git config core.hooksPath scripts/git-hooks
```
