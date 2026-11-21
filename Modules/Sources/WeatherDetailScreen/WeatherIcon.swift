import DesignSystem
import SharedModels
import SwiftUI

struct WeatherIcon: View {
    let condition: WeatherCondition
    var size: CGFloat

    var body: some View {
        Image(systemName: condition.symbolName)
            .font(.system(size: size))
            .symbolRenderingMode(.palette)
            .foregroundStyle(primaryColor, DesignSystemColor.sun)
            .accessibilityLabel(condition.displayName)
    }

    private var primaryColor: Color {
        condition == .clear ? DesignSystemColor.sun : DesignSystemColor.cloud
    }
}
