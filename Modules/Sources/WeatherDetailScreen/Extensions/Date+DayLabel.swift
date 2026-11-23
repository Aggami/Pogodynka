import Foundation

extension Date {
    func dayLabel(
        relativeTo now: Date,
        in timeZone: TimeZone,
        locale: Locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en"),
    ) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        if calendar.isDate(self, inSameDayAs: tomorrow) {
            return String(localized: "Tomorrow", bundle: .module)
        }
        return formatted(
            Date.FormatStyle(locale: locale, timeZone: timeZone)
                .weekday(.abbreviated),
        )
    }
}
