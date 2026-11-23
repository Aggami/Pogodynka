---
project: Pogodynka
version: 1
created: 2026-11-18
updated: 2026-11-18
---

# PRD — Pogodynka

## General idea

A simple iOS app for checking the weather forecast. It's a recruitment task, so
it should be solid and carefully made. The app is small, but it's built like a
large production app, ready to be maintained and to grow.

## Requirements

### Search

- FR-01: The user sees city search as the first screen when they open the app. Priority: must
- FR-02: The user's input in the city search field is validated: it doesn't accept digits, it doesn't accept special characters except hyphen and space (e.g. „Bielsko-Biała”, „Nowy Sącz”), and it accepts Polish letters. Priority: must
- FR-03: The user sees the search results in a list. Priority: must

### History

- FR-04: The user sees their search history, and it's kept between app launches. Priority: must

### Forecast details

- FR-05: The user can select a city to open its forecast details screen. Priority: must
- FR-06: On the forecast details screen, the user sees at least: the current temperature, cloud cover, the chance of rain or snow, and temperatures for the next few hours (e.g. in a table or list). Priority: must
- FR-07: On the forecast details screen, the user sees extra data, e.g. the forecast for the next days. Priority: nice

### App states

- FR-08: The user sees a dedicated state for each situation: loading, an API error, no internet connection, and an empty search result. Priority: must

### Appearance and language

- FR-09: The user can use every screen of the app in both Light and Dark Mode. Priority: must
- FR-10: The user can use the app in Polish. Priority: nice

## Out of Scope

## Future Ideas

## Open Questions

## Changelog

- v1 (2026-11-18): first version
