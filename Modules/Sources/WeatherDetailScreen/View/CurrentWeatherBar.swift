import DesignSystem
import SharedModels
import SwiftUI

struct CurrentWeatherBar: View {
    let forecast: Forecast

    var body: some View {
        VStack(spacing: 20) {
            temperatureView
            detailsGrid
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private var temperatureView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                Text(forecast.currentTemperature.displayedTemperature)
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .foregroundStyle(DesignSystemColor.text)
                WeatherIcon(condition: forecast.condition, size: 72)
            }
            HStack(spacing: 4) {
                Text("Feels like")
                    .foregroundStyle(DesignSystemColor.secondaryText)
                    .unredacted()
                Text(forecast.feelsLikeTemperature.displayedTemperature)
                    .foregroundStyle(DesignSystemColor.text)
            }
            .font(.system(size: 17))
        }
    }

    private var detailsGrid: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                detail(symbol: "cloud", "Cloud cover", "\(forecast.cloudCover)%")
                detail(symbol: "sun.max", "UV index", forecast.uvIndex.displayedUVIndex)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                detail(symbol: "drop", "Precipitation", "\(forecast.precipitationChance)%")
                detail(symbol: "wind", "Wind", forecast.windSpeed.displayedWindSpeed)
            }
        }
        .padding(.horizontal, 40)
    }

    private func detail(symbol: String, _ label: LocalizedStringKey, _ value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 24))
                .foregroundStyle(DesignSystemColor.secondaryText)
                .frame(width: 24)
                .accessibilityHidden(true)
                .unredacted()
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(DesignSystemColor.secondaryText)
                    .unredacted()
                Text(value)
                    .font(.system(size: 17))
                    .foregroundStyle(DesignSystemColor.text)
            }
        }
    }
}
