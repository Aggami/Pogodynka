---
project: Pogodynka
version: 13
prd_version: 1
created: 2026-11-18
updated: 2026-11-23
---

# Roadmap — Pogodynka

## Goal

A simple, working weather app of high quality and with nice architecture.

## Items

## Done

- CH-07: Final pass before handover: check every screen and state in Light and Dark Mode, check the README, go through the handover checklist, and build from a fresh clone. Needs: CH-06 Issue: #21
- CH-06: Add animations and visual polish. Needs: F-01, F-02, F-03 Issue: #19
- F-04: The user sees extra data on the forecast details screen, e.g. the forecast for the next days. FRs: FR-07. Needs: F-02 Issue: #17
- F-03: The user sees their search history, kept between launches. FRs: FR-04, FR-09, FR-10. Needs: F-01 Issue: #13
- F-02: The user picks a city and sees its forecast (current temperature, cloud cover, chance of rain or snow, next hours), with loading, error and no-internet states. FRs: FR-05, FR-06, FR-08, FR-09, FR-10. Needs: F-01 Issue: #11
- F-01: The user opens the app on city search, types a validated city name and sees matching cities in a list, with loading, error, no-internet and empty-result states. FRs: FR-01, FR-02, FR-03, FR-08, FR-09, FR-10. Needs: CH-02, CH-03, CH-05 Issue: #9, #10
- CH-05: Design the screens around the data the API gives, and set up the design system. Needs: CH-04 Issue: #8
- CH-03: Choose a dependency-injection approach and create the WeatherService and Persistence folders. Needs: CH-01 Issue: #4
- CH-02: Set up the app's navigation. Needs: CH-01. Issue: #3
- CH-01: Set up the Xcode project with a unit test target, check it against the task's technical requirements (iOS 17+, Xcode 26/27, SwiftUI or UIKit, cloneable git repo), and run am-init for the AI workflow. Issue: #1
- CH-04: Research which weather API is best for the app. Issue: #5

## Changelog

- v1 (2026-11-18): first version
- v2 (2026-11-19): CH-01 done
- v3 (2026-11-19): CH-04 done
- v4 (2026-11-19): CH-02 done
- v5 (2026-11-19): CH-02 narrowed to navigation; localization excluded for now
- v6 (2026-11-19): CH-03 done
- v7 (2026-11-20): CH-05 done
- v8 (2026-11-21): F-01 done
- v9 (2026-11-21): F-02 done
- v10 (2026-11-22): F-03 done
- v11 (2026-11-23): F-04 done
- v12 (2026-11-23): CH-06 done
- v13 (2026-11-23): CH-07 done
