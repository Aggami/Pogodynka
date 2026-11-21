import SharedModels

extension City {
    var locationSubtitle: String? {
        let parts = [country, region].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
