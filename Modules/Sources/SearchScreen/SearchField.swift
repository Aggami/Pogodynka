import DesignSystem
import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystemColor.secondaryText)
                .accessibilityHidden(true)
            TextField("", text: $text, prompt: prompt)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused(isFocused)
                .accessibilityLabel(Text("Search for a city", bundle: .module))
            if !text.isEmpty {
                clearButton
            }
        }
        .padding(10)
        .background(DesignSystemColor.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var prompt: Text {
        Text("Start searching a city", bundle: .module)
            .foregroundStyle(DesignSystemColor.secondaryText)
    }

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DesignSystemColor.secondaryText)
        }
        .accessibilityLabel(Text("Clear text", bundle: .module))
    }
}

#if DEBUG
    #Preview {
        @FocusState var isFocused: Bool
        SearchField(text: .constant("Wro"), isFocused: $isFocused)
            .padding()
    }
#endif
