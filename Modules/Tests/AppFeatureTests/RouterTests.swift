@testable import AppFeature
import Testing

@MainActor
struct RouterTests {
    @Test func pathIsEmptyInitially() {
        let router = Router()

        #expect(router.path.isEmpty)
    }

    @Test func pushOpensWeatherDetailForCity() {
        let router = Router()

        router.push(.weatherDetail(cityName: "Kraków"))

        #expect(router.path == [.weatherDetail(cityName: "Kraków")])
    }

    @Test func pushKeepsRoutesInOrder() {
        let router = Router()

        router.push(.weatherDetail(cityName: "Kraków"))
        router.push(.weatherDetail(cityName: "Gdańsk"))

        #expect(router.path == [
            .weatherDetail(cityName: "Kraków"),
            .weatherDetail(cityName: "Gdańsk"),
        ])
    }
}
