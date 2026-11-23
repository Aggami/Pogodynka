extension Double {
    var displayedUVIndex: String {
        "\(Int(rounded()))"
    }

    var displayedWindSpeed: String {
        "\(Int(rounded())) km/h"
    }
}
