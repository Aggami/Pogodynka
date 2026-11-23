import DesignSystem
import SharedModels
import SwiftUI

struct NextDaysList: View {
    let forecast: Forecast

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Next days", bundle: .module)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DesignSystemColor.secondaryText)
                .unredacted()
                .padding(.vertical, 8)
            ForEach(Array(forecast.upcomingDaysForecast.enumerated()), id: \.offset) { index, day in
                dailyForecastRow(day, isLast: index == forecast.upcomingDaysForecast.count - 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private func dailyForecastRow(_ day: DailyForecast, isLast: Bool) -> some View {
        let label = day.date.dayLabel(relativeTo: .now, in: forecast.timeZone)
        return HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
            WeatherIcon(condition: day.condition, size: 24)
            Text(day.minTemperature.displayedTemperature)
                .foregroundStyle(DesignSystemColor.secondaryText)
                .frame(width: 44, alignment: .trailing)
            Text(day.maxTemperature.displayedTemperature)
                .foregroundStyle(DesignSystemColor.text)
                .frame(width: 44, alignment: .trailing)
        }
        .font(.system(size: 17).monospacedDigit())
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            if !isLast {
                DesignSystemColor.divider.frame(height: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(
            localized: """
            \(label), \(day.condition.displayName.lowercased()), lowest \(day.minTemperature.displayedTemperature), \
            highest \(day.maxTemperature.displayedTemperature)
            """,
            bundle: .module,
        ))
    }
}
