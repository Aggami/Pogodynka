import Foundation

extension Date {
    func hourLabel(in timeZone: TimeZone) -> String {
        formatted(
            Date.FormatStyle(locale: Locale(identifier: "en_GB"), timeZone: timeZone)
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits),
        )
    }
}
