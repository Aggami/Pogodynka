# Project setup decisions

Why the Xcode project is set up the way it is (ticket #1).

## Thin app + local package

- Xcode buildable folders only avoid project-file merge conflicts. They give no
  module boundaries, no `internal` separation and no per-module tests. A
  package gives all three.
- Code is imported by module name (`import AppFeature`). The package name
  `Modules` is never imported, so it can't clash with anything.
- The package has its own unit tests (`AppFeatureTests`), so the app scheme
  doesn't carry them.
- Later modules (WeatherService, Persistence) are added to the package without
  touching the app target.

## Workspace

- Xcode couldn't add the package's test target to the app scheme's test plan.
  With `Pogodynka.xcworkspace` (app project + `Modules` package) the package
  gets its own scheme, and its tests run with no extra setup.

## Costs

- Package resources need `bundle: .module`.
- iOS-only code is tested with `xcodebuild` on a simulator, not `swift test`.

## Other choices

- Swift Testing is the test framework.
- SwiftFormat and SwiftLint run only in the git pre-commit hook, not as an
  Xcode build plugin.
