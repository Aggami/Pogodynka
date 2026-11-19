@testable import AppFeature
import Testing

@MainActor
struct RouterTests {
    @Test func `starts on search screen`() {
        let router = Router()

        #expect(router.path.isEmpty)
    }

    @Test func `push opens weather detail for city`() {
        let router = Router()

        router.push(.weatherDetail(cityName: "Kraków"))

        #expect(router.path == [.weatherDetail(cityName: "Kraków")])
    }

    @Test func `push keeps routes in order`() {
        let router = Router()

        router.push(.weatherDetail(cityName: "Kraków"))
        router.push(.weatherDetail(cityName: "Gdańsk"))

        #expect(router.path == [
            .weatherDetail(cityName: "Kraków"),
            .weatherDetail(cityName: "Gdańsk"),
        ])
    }
}
