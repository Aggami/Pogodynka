import DesignSystem
import SharedModels
import SwiftUI

struct CityRow: View {
    let city: City

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.title3)
                    .foregroundStyle(DesignSystemColor.text)
                if let subtitle = city.locationSubtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(DesignSystemColor.secondaryText)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(DesignSystemColor.accent)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}
