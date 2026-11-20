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
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(DesignSystemColor.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(DesignSystemColor.accent)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        if let region = city.region {
            "\(city.country), \(region)"
        } else {
            city.country
        }
    }
}
