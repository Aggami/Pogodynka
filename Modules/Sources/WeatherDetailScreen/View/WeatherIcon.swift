import SharedModels
import SwiftUI

struct WeatherIcon: View {
    @Environment(\.redactionReasons) private var redactionReasons

    let condition: WeatherCondition
    var size: CGFloat

    var body: some View {
        if redactionReasons.contains(.placeholder) {
            Circle()
                .fill(.placeholder)
                .frame(width: size, height: size)
                .unredacted()
        } else {
            let icon = condition.icon
            Image(systemName: icon.symbolName)
                .font(.system(size: size))
                .symbolRenderingMode(.palette)
                .foregroundStyle(icon.mainColor, icon.secondaryColor, icon.tertiaryColor)
                .accessibilityLabel(condition.displayName)
        }
    }
}
