import Foundation

enum HourLabel {
    static func text(for time: Date, isFirst: Bool, in timeZone: TimeZone) -> String {
        if isFirst { return "Now" }
        return time.formatted(
            Date.FormatStyle(locale: Locale(identifier: "en_GB"), timeZone: timeZone)
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits),
        )
    }
}
