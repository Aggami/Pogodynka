import DesignSystem
import SharedModels
import SwiftUI

struct HourlyForecastTable: View {
    let forecast: Forecast

    private let labelWidth: CGFloat = 48
    private let columnWidth: CGFloat = 56

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            labelColumn
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(forecast.hours.enumerated()), id: \.offset) { index, hour in
                        hourColumn(hour, isFirst: index == 0)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private var labelColumn: some View {
        VStack(spacing: 0) {
            cell(height: Row.hour.height) { Text(verbatim: "") }
            cell(height: Row.icon.height) { Text(verbatim: "") }
            cell(height: Row.precipitation.height) { Text("Precip.").unredacted() }
            cell(height: Row.temperature.height, showsDivider: false) { Text("Temp").unredacted() }
        }
        .font(.system(size: 13))
        .foregroundStyle(DesignSystemColor.secondaryText)
        .frame(width: labelWidth)
        .accessibilityHidden(true)
    }

    private func hourColumn(_ hour: HourlyForecast, isFirst: Bool) -> some View {
        let label = isFirst ? "Now" : hour.time.hourLabel(in: forecast.timeZone)
        return VStack(spacing: 0) {
            cell(height: Row.hour.height) {
                Text(label)
                    .font(.system(size: 13, weight: isFirst ? .semibold : .regular))
                    .foregroundStyle(DesignSystemColor.secondaryText)
            }
            cell(height: Row.icon.height) {
                WeatherIcon(condition: hour.condition, size: 24)
            }
            cell(height: Row.precipitation.height) { value("\(hour.precipitationChance)%") }
            cell(height: Row.temperature.height, showsDivider: false) {
                value(hour.temperature.displayedTemperature)
            }
        }
        .frame(width: columnWidth)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(label), \(hour.condition.displayName.lowercased()), precipitation \(hour.precipitationChance)%, "
                + hour.temperature.displayedTemperature,
        )
    }

    private func value(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17).monospacedDigit())
            .foregroundStyle(DesignSystemColor.text)
    }

    private func cell(
        height: CGFloat,
        showsDivider: Bool = true,
        @ViewBuilder content: () -> some View,
    ) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    DesignSystemColor.divider.frame(height: 1)
                }
            }
    }

    private enum Row {
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
