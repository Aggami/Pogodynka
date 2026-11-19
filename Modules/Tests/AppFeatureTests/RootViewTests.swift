import AppFeature
import SwiftUI
import Testing

struct RootViewTests {
    @Test @MainActor func `root view can be created from outside the module`() {
        let view = RootView()
        _ = view.body
    }
}
