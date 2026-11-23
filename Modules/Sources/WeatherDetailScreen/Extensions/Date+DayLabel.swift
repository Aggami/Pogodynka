import Foundation

extension Date {
    func dayLabel(relativeTo now: Date, in timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        if calendar.isDate(self, inSameDayAs: tomorrow) {
            return "Tomorrow"
        }
        return formatted(
            Date.FormatStyle(locale: Locale(identifier: "en_GB"), timeZone: timeZone)
                .weekday(.abbreviated),
        )
    }
}
