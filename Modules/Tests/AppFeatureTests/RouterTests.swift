@testable import AppFeature
import SharedModels
import Testing

@MainActor
struct RouterTests {
    private let krakow = City(name: "Kraków", country: "Polska", region: "małopolskie")
    private let gdansk = City(name: "Gdańsk", country: "Polska", region: "pomorskie")

    @Test func pathIsEmptyInitially() {
        let router = Router()

        #expect(router.path.isEmpty)
    }

    @Test func pushOpensWeatherDetailForCity() {
        let router = Router()

        router.push(.weatherDetail(krakow))

        #expect(router.path == [.weatherDetail(krakow)])
    }

    @Test func pushKeepsRoutesInOrder() {
        let router = Router()

        router.push(.weatherDetail(krakow))
        router.push(.weatherDetail(gdansk))

        #expect(router.path == [
            .weatherDetail(krakow),
            .weatherDetail(gdansk),
        ])
    }
}
