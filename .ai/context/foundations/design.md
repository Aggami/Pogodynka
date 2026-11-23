# Design — Pogodynka

Issue: #8 (CH-05). Canvas (private): https://claude.ai/artifact/84HU7ZzzCb1RTbkDx5kZ9W

The canvas has two pages:

1. **Screens**: the core idea and how the app behaves. Grey wireframes of
   every screen and state, with the decided rules (blue notes) and open
   questions (orange notes).
2. **Palette**: the MVP design. The approved colour palette and the loaded
   screens drawn in it, in Light and Dark Mode. Below them: a future idea
   (gradient) and the explored options, kept for reference.

Everything marked [PLACEHOLDER] on the canvas is not decided yet. All
temperatures, hours, days, percentages and the Kraków / Gdańsk rows are sample
data.

## 1. Core idea and app behavior (Screens page)

### Search screen

One screen for search and history.

- Large title "Pogodynka". Search bar at the top, placeholder
  "Start searching a city".
- UI text in English; place data in Polish ("Polska, dolnośląskie").
- **Normal (recent searches)**: clock icon + "Recent searches" header. Each
  row: city name (large), "Polska, region" (smaller, below), chevron on the
  right. Tapping a row opens the forecast. No weather in the rows.
- **No history yet**: an image (magnifying glass, temporary), a title (not
  decided) and the text "Start searching for a city around the world to see
  the weather forecast."
- **Loading**: search starts after at least 3 characters; a spinner shows
  below the search bar.
- **Results loaded**: results replace the history and look like history rows.
- **Errors**: probably alerts for most cases; not final.

### Forecast screen

- **Navigation bar**: back button with the chevron only. The city name is an
  iOS large title below it and shrinks into the bar on scroll.
- **Current weather bar**: a big current temperature and an image for
  cloudiness.
- **Next hours**: a table with the chance of precipitation and the temperature
  for the next few hours. Two versions are kept for now: hours horizontal
  (hours in columns, rows Rain / Temp) and hours vertical (one row per hour).
- **Next days**: the horizontal version also has a vertical table with the
  next days (day, image, min, max).
- **Attribution**: "Weather data by Open-Meteo.com" next to the data
  (Open-Meteo's terms).
- **Loading**: skeletons in place of the content, for both versions.

### Forecast screen: next days and more details (#17, approved)

Claude Design (private): https://claude.ai/artifact/WGLVgabTaA2fmNcyA3hsT7
(loaded and loading, Light and Dark Mode; all values are sample data).

Layout, top to bottom:

1. **Navigation bar**: unchanged (chevron-only back button, city as a large
   title).
2. **Current weather bar** (surface background, corner radius 12):
   - Big temperature + weather icon, centred, as before.
   - Below them, centred: **"Feels like 1°"** ("Feels like" in
     secondaryText, the value in text colour).
   - Below that, a 2×2 grid. Each item: an icon (24 pt, line style,
     secondaryText colour, 10 pt gap), then the label above the value (label
     13 pt secondaryText, value 17 pt text): **"Cloud cover"** 70% (cloud
     icon) · **"Precipitation today"** 60% (a drop and a snowflake side by
     side, for rain or snow; in code the SF Symbols `drop` and `snowflake`,
     smaller, in the same 24 pt space) · **"UV index"** 1 (sun) ·
     **"Wind"** 18 km/h (wind lines). The icons are grey, not coloured, so
     they aren't confused with the weather icon; they are decorative
     (hidden from VoiceOver).
   - Grid alignment: the left column starts at the left, the right column
     ends at the right edge (columns pushed apart); content inside both
     columns is left-aligned. The grid has 24 pt extra horizontal padding
     inside the bar (40 pt from the bar's edges in total) and 20 pt between
     the rows. The bar's padding is 24 pt top and bottom, 20 pt between its
     parts.
3. **Hourly table**: 12 hours, scrolls sideways. Rows: hour ("Now" first),
   icon, **"Precip."** (chance of precipitation, %), "Temp". Label column
   60 pt. VoiceOver reads "Precip." as "Precipitation".
4. **Next days**: title **"Next days"** (13 pt semibold, secondaryText), not
   "Next 6 days", because a day with missing data is left out. Up to 6 rows,
   the days after today. Row (44 pt, divider below): day label, icon,
   lowest temperature (secondaryText), highest temperature (text), both
   right-aligned. Day labels: **"Tomorrow"** for the first day, then short
   weekday names (**"Wed"**, "Thu", …).
5. **Attribution**: "Weather data by Open-Meteo.com", unchanged.

Texts and units:

- "Chance of rain or snow" in the bar is now **"Precipitation today"**: the
  highest hourly chance among the next 12 fetched hours that are still today
  (city's time zone).
- Hourly row "Rain" → **"Precip."**.
- Wind speed in **km/h**, a whole number.
- UV index as a **rounded number** only (e.g. "UV index 3"), no level words.
- Feels like: a whole number with "°", like the other temperatures.

Loading (skeletons):

- SwiftUI's standard `.redacted(reason: .placeholder)`; the canvas shows
  placement, not the exact look.
- Fixed labels stay as text (`.unredacted()`): "Feels like", "Cloud cover",
  "Precipitation today", "UV index", "Wind", "Precip.", "Temp", "Next days".
- Data is redacted: temperature and icon, all values, the hours ("Now"
  included), hourly icons and numbers, day names, day icons and
  temperatures (6 placeholder rows).
- The bar's grey detail icons stay visible too (`.unredacted()`), like the
  labels.
- City name and back button stay real; attribution hidden while loading.

Icons:

- Snow (`cloud.snow.fill`): snowflakes in the new **snow** colour (light blue
  in Light Mode, white in Dark Mode) instead of white in both; white flakes
  disappear on the white Light Mode background.

### Not drawn yet

- Search: error, no internet, empty results.
- Forecast: error, no internet.
- Dark Mode versions of the Screens page. The Palette page shows the loaded
  states in Dark Mode.

### Still open

- Search: no-history title and image; text sizes; a way to clear the history;
  what shows with 1–2 characters typed; a header above results; loading text;
  which errors are alerts and their wording; the exact Polish region text from
  Open-Meteo (to check with a real call).
- Forecast: the current bar's arrangement and sizes, condition text, cloud
  cover as a % or image only; horizontal or vertical hours (which one stays);
  hours table title; other extra data; attribution position; skeleton
  animation. (Decided in #17: the bar's new values and their labels, the
  hourly row label, 12 hours scrolling sideways, the next-days title, number
  of days, columns and day labels, skeleton placement, see "Forecast screen:
  next days and more details".)
- Forecast: rain drops (`precipitation`, `#4FA3F7`) are only about 2.7:1 on
  the white Light Mode background, below the 3:1 for icons. Not changed in
  #17.

## 2. MVP design (Palette page)

The approved palette: **Version 1 (minimal colour)** in Light Mode, with
**Dark Mode option C** (navy-tinted dark grey).

- Light Mode: white background, black text. Colour only on the chevrons, the
  clock icon and the weather icons. Grey bar and search field.
- Dark Mode: navy-tinted dark grey background, lighter navy-grey bar and
  search field, white text.

### Palette

The role names are working names. In code the palette lives in
`DesignSystem.DesignSystemColor` (an asset catalog).

| Role | Used for | Light | Dark |
|---|---|---|---|
| background | Screen background | `#FFFFFF` | `#0F141C` |
| surface | Current weather bar, search field | `#F2F2F7` | `#26334A` |
| text | Text and titles | `#000000` | `#FFFFFF` |
| secondaryText | Region, labels, attribution, placeholder | `#6B6B70` | `#A3B1C6` |
| divider | Row and table dividers | `#E3E3E6` | `#2C3850` |
| accent | Chevrons, clock icon | `#1D5FCC` | `#7FAEF5` |
| sun | Sun in weather icons | `#C2620A` | `#FDCA40` |
| cloud | Cloud in weather icons | `#1D5FCC` | `#7FAEF5` |
| precipitation | Rain drops in weather icons (in code, not on the canvas) | `#4FA3F7` | `#3D7AD6` |
| snow | Snowflakes in weather icons (#17) | `#3B8EDB` | `#FFFFFF` |

Contrast (WCAG): text is at least 4.5:1 on the background, and the accent
and icons are at least 3:1 on the background or the bar (snow `#3B8EDB`:
3.5:1 on white, 3.1:1 on the bar). Exception: `precipitation` in Light Mode
is about 2.7:1 on white (see "Still open").

### Still open

- Increased-contrast variants (Apple's HIG asks for them): not defined.
- The palette isn't applied to the Screens page; that page stays grey.
- The Palette page shows loaded states only.

### Future idea: sky gradient (not in the MVP)

Drawn on the Palette page as "Version 3". The forecast screen gets a sky
gradient background (`#1F55B0` → `#13315C` in Light Mode, `#152B52` →
`#050B18` in Dark Mode), a frosted current weather bar, white text and filled
icons. Open: should the gradient follow Light/Dark Mode, day and night, or the
weather?
