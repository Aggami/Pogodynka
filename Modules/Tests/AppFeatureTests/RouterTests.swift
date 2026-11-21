@testable import AppFeature
import SharedModels
import Testing

@MainActor
struct RouterTests {
    private let krakow = City(
        id: 1,
        name: "Kraków",
        latitude: 50.06,
        longitude: 19.94,
        country: "Polska",
        region: "małopolskie",
    )
    private let gdansk = City(
        id: 2,
        name: "Gdańsk",
        latitude: 54.35,
        longitude: 18.65,
        country: "Polska",
        region: "pomorskie",
    )

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
