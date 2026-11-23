import DesignSystem
import SharedModels
import SwiftUI

struct HourlyForecastTable: View {
    let forecast: Forecast

    private let columnWidth: CGFloat = 56

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            labelGrid
            ScrollView(.horizontal, showsIndicators: false) {
                hoursGrid
            }
        }
        .padding(.vertical, 8)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private var labelGrid: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow { Color.clear.frame(width: 0, height: ConditionRowType.hour.height) }
            divider
            GridRow { Color.clear.frame(width: 0, height: ConditionRowType.icon.height) }
            divider
            GridRow {
                Text("Precip.", bundle: .module).unredacted()
                    .frame(height: ConditionRowType.precipitation.height)
            }
            divider
            GridRow {
                Text("Temp", bundle: .module).unredacted()
                    .frame(height: ConditionRowType.temperature.height)
            }
        }
        .font(.system(size: 13))
        .foregroundStyle(DesignSystemColor.secondaryText)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 8)
        .accessibilityHidden(true)
    }

    private var hoursGrid: some View {
        let hours = Array(forecast.upcomingHoursForecast.enumerated())
        return Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ForEach(hours, id: \.offset) { index, hour in
                    Text(hourLabel(hour, isFirst: index == 0))
                        .font(.system(size: 13, weight: index == 0 ? .semibold : .regular))
                        .foregroundStyle(DesignSystemColor.secondaryText)
                        .frame(width: columnWidth, height: ConditionRowType.hour.height)
                }
            }
            divider
            GridRow {
                ForEach(hours, id: \.offset) { _, hour in
                    WeatherIcon(condition: hour.condition, size: 24)
                        .frame(height: ConditionRowType.icon.height)
                }
            }
            divider
            GridRow {
                ForEach(hours, id: \.offset) { _, hour in
                    value("\(hour.precipitationChance)%")
                        .frame(height: ConditionRowType.precipitation.height)
                }
            }
            divider
            GridRow {
                ForEach(hours, id: \.offset) { _, hour in
                    value(hour.temperature.displayedTemperature)
                        .frame(height: ConditionRowType.temperature.height)
                }
            }
        }
        .accessibilityRepresentation {
            VStack {
                ForEach(hours, id: \.offset) { index, hour in
                    Text(String(
                        localized: """
                        \(hourLabel(hour, isFirst: index == 0)), \(hour.condition.displayName.lowercased()), \
                        precipitation \(hour.precipitationChance)%, \(hour.temperature.displayedTemperature)
                        """,
                        bundle: .module,
                    ))
                }
            }
        }
    }

    private var divider: some View {
        DesignSystemColor.divider.frame(height: 1)
    }

    private func hourLabel(_ hour: HourlyForecast, isFirst: Bool) -> String {
        isFirst ? String(localized: "Now", bundle: .module) : hour.time.hourLabel(in: forecast.timeZone)
    }

    private func value(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17).monospacedDigit())
            .foregroundStyle(DesignSystemColor.text)
    }

    private enum ConditionRowType {
        case hour, icon, precipitation, temperature

        var height: CGFloat {
            switch self {
            case .hour: 32
            case .icon: 44
            case .precipitation, .temperature: 40
            }
        }
    }
}
