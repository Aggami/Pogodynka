import DesignSystem
import SharedModels
import SwiftUI

struct CurrentWeatherBar: View {
    let forecast: Forecast

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                Text(TemperatureText.text(forecast.currentTemperature))
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .foregroundStyle(DesignSystemColor.text)
                WeatherIcon(condition: forecast.condition, size: 72)
            }
            VStack(spacing: 4) {
                Text("Cloud cover \(forecast.cloudCover)%")
                Text("Chance of rain or snow \(forecast.precipitationChance)%")
            }
            .foregroundStyle(DesignSystemColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}
