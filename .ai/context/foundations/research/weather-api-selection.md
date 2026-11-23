# Weather API for Pogodynka — research

Ticket: #5 · Date: 2026-11-19

## Problem

The iOS app needs a weather API that does city search (FR-03) and, for a chosen
city, returns the current temperature, cloud cover, chance of rain or snow, and
an hourly forecast (FR-06). A daily forecast (FR-07) and Polish city names /
language (FR-02, FR-10) are a bonus. It's a non-commercial recruitment project,
so the API should be free or have a good free tier.

## Approaches

**Open-Meteo** — Open-source API that combines national weather models. Own city
search, no key on the free tier. Conditions come only as numeric codes.
[Forecast docs + URL builder](https://open-meteo.com/en/docs) ·
[Geocoding](https://open-meteo.com/en/docs/geocoding-api) ·
[Terms](https://open-meteo.com/en/terms)

**OpenWeatherMap** — Well-known REST API split into products. Free plan has
Geocoding, Current Weather and a 5-day forecast in 3-hour steps; true hourly
data needs One Call (1,000 free calls/day, but asks for billing details).
[One Call 3.0](https://openweathermap.org/api/one-call-3) ·
[Geocoding](https://openweathermap.org/api/geocoding-api) ·
[Pricing](https://openweathermap.org/full-price)

**AccuWeather** — Commercial API; every weather call uses a "location key", so
city search is always step 1. No permanent free tier: 14-day trial, then
$2/month.
[Overview](https://developer.accuweather.com/documentation/overview) ·
[Location keys](https://developer.accuweather.com/documentation/location-keys) ·
[FAQ](https://developer.accuweather.com/faq)

**WeatherAPI.com** — Commercial API with a permanent free plan. One key covers
search, current weather and forecast; condition texts in Polish. Free forecast
covers only 3 days.
[Docs](https://www.weatherapi.com/docs/) ·
[OpenAPI spec](https://www.weatherapi.com/openapi.json) ·
[Pricing](https://www.weatherapi.com/pricing.aspx)

**Apple WeatherKit** — Apple's native Swift framework (iOS 16+). No city search
(use MapKit). Works only for apps signed by a paid Apple Developer Program team.
[Get started](https://developer.apple.com/weatherkit/get-started/) ·
[Swift API](https://developer.apple.com/documentation/weatherkit/weatherservice) ·
[REST API](https://developer.apple.com/documentation/weatherkitrestapi)

**Tomorrow.io** — Commercial "weather intelligence" REST API with many data
fields. One call accepts a city name, but no search endpoint returning a list of
matches, and no Polish.
[Forecast](https://docs.tomorrow.io/reference/weather-forecast) ·
[Data layers](https://docs.tomorrow.io/reference/weather-data-layers) ·
[Core fields](https://docs.tomorrow.io/reference/data-layers-core)

## Comparison

| Criterion | Open-Meteo | OpenWeatherMap | AccuWeather | WeatherAPI.com | WeatherKit | Tomorrow.io |
|---|---|---|---|---|---|---|
| **1. Cost / free tier** | Free; 600/min, 10k/day, 300k/month | Free 60/min, 1M/month; One Call 1k/day free (billing form) | 14-day trial (500/day), then $2/month, 15k/month | Free forever; 100k/month, no card | 500k/month in the $99/year Apple Developer membership | Free; 500/day, 25/hour |
| **2. City search** | ✅ own geocoding API | ✅ Geocoding API (max 5 results) | ✅ search + autocomplete | ✅ search/autocomplete | ❌ (use MapKit) | ❌ name→1 place only, no list |
| **3. FR-06 data** | ✅ all; rain chance hourly only | ⚠️ free = 3-hour steps; hourly via One Call | ✅; Starter = 12 h | ✅ all, with rain and snow chances | ✅ all; rain chance via current hour | ✅ all; hourly up to +5 days |
| **4. Data scope / extras** | AQI, pollen, UV, marine, flood, historical since 1940, 15-min, model choice | AQI, maps, minutely, alerts, history since 1979, AI summary | Indices, alerts, MinuteCast, lightning, pollen | AQI, alerts, astronomy, sports; marine/pollen paid | Next-hour rain, alerts, UV, sun/moon, historical stats | 80+ fields (fire, flood, road…); many premium |
| **5. Polish city names** | ✅ tested: "Nowy Sacz"→"Nowy Sącz", `language=pl` | ⚠️ `local_names` (per-language, varies by place); diacritics unknown — no example found, needs a live test | Unknown (local names "first") | Unknown — no example found, needs a live test | Unknown (MapKit) | Unknown |
| **6. Polish language** | Geocoding only; weather has codes only | ✅ `lang=pl` for descriptions | Unconfirmed (no `pl` listed) | ✅ `lang=pl` ("Słonecznie") | Localized description; Polish unknown | ❌ |
| **7. Daily forecast** | 16 days | Free: none (group 3-hour steps); One Call: 8 days | Starter: 5 days | 3 days on free | 10 days | 5 days |
| **8. Auth** | None | Key in query `appid` (active ≤2 h after signup) | Bearer key in header | Key in query `key` | Entitlement (Swift); JWT (REST) | Key in query or header |
| **9. Docs quality** | Very good: URL builder, OpenAPI | Good per endpoint; pricing pages contradict each other | Medium; gaps (languages) | Good: OpenAPI, Explorer; some pages thin | Good reference; weak on localization | Mixed; contradictions |
| **10. Licence** | Non-commercial only on free; CC BY 4.0 | Commercial OK on free; ODbL | Starter: personal / non-commercial | Commercial OK on free; 1 key = 1 app | Commercial OK; no reselling raw data | Commercial banned on free |
| **11. API shape** | GET by lat/lon; JSON parallel arrays (`time[]`, `temp[]`) | GET by lat/lon; `/geo`, `/weather`, `/forecast`, `/onecall` | Search → `Key` → `/currentconditions/{key}`, `/forecasts/…/{key}` | GET `q=` name / lat,lon / `id:`; `location`, `current`, `forecastday[].hour[24]` | `WeatherService.weather(for:including:)` → typed structs | GET `/weather/forecast?location=`; `timelines.hourly[]{time, values}` |
| **12. Swift SDK / testability** | ✅ official SPM (FlatBuffers, binary fixtures); or plain JSON + Codable | ❌ no official one; JSON fixtures | ❌ none; JSON fixtures | ❌ only an old Obj-C pod (2020); JSON fixtures | ✅ native; no public inits, so wrap in own models | ❌ none; JSON fixtures from docs |
| **13. Ban on mixing data** | None (CC BY allows remixing) | None; share-alike if you republish a combined dataset | ✅ **banned** | None | None found | None found |
| **14. Caching** | No limit found | No time limit found; storing allowed under ODbL (share-alike if you republish a dataset) | Up to 2 weeks | Current ≤60 min, forecast ≤24 h | "Temporary and limited" only | Restricted; short cache unclear |
| **15. Attribution** | Link "Weather data by Open-Meteo.com" next to data | Text + link + logo on the data screen | Linked logo ≥70px on every screen | Name or logo (terms) | Apple Weather mark + legal link | "Powered by Tomorrow.io" + link near data |
| **16. Condition format** | Numeric WMO code only | `id` + `main` (English only) + `description` (pl) + icon code | `WeatherText` (localized) + icon 1–44 | `text` (pl) + `code` + icon URL | Enum + localized description + SF Symbol name | Numeric code only (English list) |

## Choice

**Open-Meteo.**

- **Dropped first:** WeatherKit, Tomorrow.io, AccuWeather — the app should keep
  working later without a paid plan or a paid developer account.
- **Finalists:** Open-Meteo, OpenWeatherMap, WeatherAPI.com. Commercial use
  doesn't matter for this app. On cost: "For the calls and the number of requests I think they are pretty similar, like all should be more than enough for me. Only the open weather map hourly limit might be slightly too little during the development phase and a little bit risky maybe, so that's a minus on its side, but generally the calls I don't need to mark it as a big difference."
  (OpenWeatherMap's free limit is 60 calls/minute.)
- **Why Open-Meteo:** no API key; real hourly data and a 16-day daily forecast;
  Polish city names tested; best docs. Numeric weather codes are fine: one small
  Swift mapping (WMO code → Polish text + SF Symbol) instead of a package; the
  JSON is decoded with plain `URLSession` + `Codable`.
- **Accepted trade-offs:** no condition text (own mapping), parallel arrays to
  zip, precipitation chance only hourly (take the current hour), attribution
  link "Weather data by Open-Meteo.com" next to the data.
