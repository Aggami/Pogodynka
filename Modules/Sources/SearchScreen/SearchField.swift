import DesignSystem
import SwiftUI

struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystemColor.secondaryText)
                .accessibilityHidden(true)
            TextField("", text: $text, prompt: prompt)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityLabel("Search for a city")
            if !text.isEmpty {
                clearButton
            }
        }
        .padding(10)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var prompt: Text {
        Text("Start searching a city")
            .foregroundStyle(DesignSystemColor.secondaryText)
    }

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DesignSystemColor.secondaryText)
        }
        .accessibilityLabel("Clear text")
    }
}

#if DEBUG
    #Preview {
        SearchField(text: .constant("Wro"))
            .padding()
    }
#endif
