@testable import SearchScreen
import SharedModels
import Testing

@MainActor
struct CityRowTests {
    private func subtitle(country: String?, region: String?) -> String? {
        let city = City(id: 1, name: "Wrocław", latitude: 51.1, longitude: 17.03, country: country, region: region)
        return CityRow(city: city).subtitle
    }

    @Test func countryAndRegionAreJoined() {
        #expect(subtitle(country: "Polska", region: "dolnośląskie") == "Polska, dolnośląskie")
    }

    @Test func onlyCountryShowsCountry() {
        #expect(subtitle(country: "Polska", region: nil) == "Polska")
    }

    @Test func onlyRegionShowsRegion() {
        #expect(subtitle(country: nil, region: "dolnośląskie") == "dolnośląskie")
    }

    @Test func neitherGivesNoSubtitle() {
        #expect(subtitle(country: nil, region: nil) == nil)
    }
}
