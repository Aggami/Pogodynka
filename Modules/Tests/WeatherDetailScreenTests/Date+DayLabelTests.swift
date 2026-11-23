import Foundation
import Testing
@testable import WeatherDetailScreen

struct DateDayLabelTests {
    private let warsaw = TimeZone(identifier: "Europe/Warsaw") ?? .gmt
    /// 2026-11-25 (Wednesday) 12:00 UTC
    private let now = Date(timeIntervalSince1970: 1_795_608_000)

    @Test func theDayAfterNowIsTomorrow() {
        #expect(now.addingTimeInterval(86400).dayLabel(relativeTo: now, in: warsaw) == "Tomorrow")
    }

    @Test func laterDaysShowTheShortWeekday() {
        #expect(now.addingTimeInterval(2 * 86400).dayLabel(relativeTo: now, in: warsaw) == "Fri")
    }

    @Test func daysFollowTheCitysTimeZone() {
        // 23:30 UTC on Wednesday is already 00:30 Thursday in Warsaw
        let lateNow = Date(timeIntervalSince1970: 1_795_649_400)
        #expect(lateNow.addingTimeInterval(86400).dayLabel(relativeTo: lateNow, in: warsaw) == "Tomorrow")
        #expect(lateNow.addingTimeInterval(2 * 86400).dayLabel(relativeTo: lateNow, in: warsaw) == "Sat")
    }
}
