import SwiftUI
import Testing
import AppFeature

struct RootViewTests {
    @Test @MainActor func rootViewCanBeCreatedFromOutsideTheModule() {
        let view = RootView()
        _ = view.body
    }
}
