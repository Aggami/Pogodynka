import Foundation
import Testing
@testable import WeatherDetailScreen

struct HourLabelTests {
    private let warsaw = TimeZone(identifier: "Europe/Warsaw") ?? .gmt
    private let tokyo = TimeZone(identifier: "Asia/Tokyo") ?? .gmt
    /// 2026-11-21 14:00 UTC
    private let moment = Date(timeIntervalSince1970: 1_795_269_600)

    @Test func firstHourIsNow() {
        #expect(HourLabel.text(for: moment, isFirst: true, in: warsaw) == "Now")
    }

    @Test func otherHoursUseTheCitysLocalTime() {
        #expect(HourLabel.text(for: moment, isFirst: false, in: warsaw) == "15:00")
        #expect(HourLabel.text(for: moment, isFirst: false, in: tokyo) == "23:00")
    }

    @Test func hoursFollowDaylightSavingTime() {
        // 2026-07-01 12:00 UTC: Warsaw is on summer time (UTC+2)
        let summer = Date(timeIntervalSince1970: 1_782_907_200)
        #expect(HourLabel.text(for: summer, isFirst: false, in: warsaw) == "14:00")
    }
}
