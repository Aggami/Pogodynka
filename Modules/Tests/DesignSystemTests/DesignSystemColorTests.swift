@testable import DesignSystem
import SwiftUI
import Testing
import UIKit

struct DesignSystemColorTests {
    @Test(arguments: expectedColors)
    func colorResolvesToItsLightHexInLightMode(expected: ExpectedColor) {
        #expect(hex(of: expected.color, in: .light) == expected.light)
    }

    @Test(arguments: expectedColors)
    func colorResolvesToItsDarkHexInDarkMode(expected: ExpectedColor) {
        #expect(hex(of: expected.color, in: .dark) == expected.dark)
    }
}

extension DesignSystemColorTests {
    struct ExpectedColor: CustomTestStringConvertible {
        let name: String
        let color: Color
        let light: UInt32
        let dark: UInt32

        var testDescription: String {
            name
        }
    }

    static let expectedColors = [
        ExpectedColor(name: "background", color: DesignSystemColor.background, light: 0xFFFFFF, dark: 0x0F141C),
        ExpectedColor(name: "surface", color: DesignSystemColor.surface, light: 0xF2F2F7, dark: 0x26334A),
        ExpectedColor(name: "text", color: DesignSystemColor.text, light: 0x000000, dark: 0xFFFFFF),
        ExpectedColor(name: "secondaryText", color: DesignSystemColor.secondaryText, light: 0x6B6B70, dark: 0xA3B1C6),
        ExpectedColor(name: "divider", color: DesignSystemColor.divider, light: 0xE3E3E6, dark: 0x2C3850),
        ExpectedColor(name: "accent", color: DesignSystemColor.accent, light: 0x1D5FCC, dark: 0x7FAEF5),
        ExpectedColor(name: "sun", color: DesignSystemColor.sun, light: 0xC2620A, dark: 0xFDCA40),
        ExpectedColor(name: "cloud", color: DesignSystemColor.cloud, light: 0x1D5FCC, dark: 0x7FAEF5),
        ExpectedColor(name: "precipitation", color: DesignSystemColor.precipitation, light: 0x4FA3F7, dark: 0x3D7AD6),
    ]

    private func hex(of color: Color, in style: UIUserInterfaceStyle) -> UInt32 {
        let resolved = UIColor(color).resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let redByte = UInt32((red * 255).rounded())
        let greenByte = UInt32((green * 255).rounded())
        let blueByte = UInt32((blue * 255).rounded())
        return redByte << 16 | greenByte << 8 | blueByte
    }
}
