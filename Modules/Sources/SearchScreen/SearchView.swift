import SwiftUI

public struct SearchView: View {
    private let onCitySelected: (String) -> Void

    public init(onCitySelected: @escaping (String) -> Void) {
        self.onCitySelected = onCitySelected
    }

    public var body: some View {
        VStack(spacing: 24) {
            Text("City search")
                .font(.largeTitle)
            Button("Show sample city") {
                onCitySelected("Kraków")
            }
        }
    }
}

#Preview {
    SearchView { _ in }
}
