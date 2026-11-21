#if DEBUG
    import SharedModels

    public struct PreviewSearchHistoryStore: SearchHistoryStoreProtocol {
        public let hasHistory: Bool

        public init(hasHistory: Bool) {
            self.hasHistory = hasHistory
        }

        public func loadHistory() async throws -> [City] {
            guard hasHistory else { return [] }
            return [
                City(
                    id: 1,
                    name: "Wrocław",
                    latitude: 51.1,
                    longitude: 17.03,
                    country: "Polska",
                    region: "dolnośląskie",
                ),
                City(
                    id: 2,
                    name: "Kraków",
                    latitude: 50.06,
                    longitude: 19.94,
                    country: "Polska",
                    region: "małopolskie",
                ),
                City(id: 3, name: "Tokyo", latitude: 35.69, longitude: 139.69, country: "Japonia"),
            ]
        }

        public func save(_: City) async throws {}
    }
#endif
