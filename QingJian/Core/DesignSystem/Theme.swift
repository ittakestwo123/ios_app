import SwiftUI
import UIKit

enum QingTheme {
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    enum Radius {
        static let card: CGFloat = 22
        static let control: CGFloat = 14
        static let capsule: CGFloat = 999
    }

    static let mistGreen = Color.adaptive(light: 0x789F91, dark: 0x9DC7B8)
    static let pineInk = Color.adaptive(light: 0x31584F, dark: 0xB4D7CC)
    static let paper = Color.adaptive(light: 0xFAF8F1, dark: 0x15221E)
    static let apricot = Color.adaptive(light: 0xEECFB7, dark: 0x6A5040)
    static let morningGold = Color.adaptive(light: 0xD9B76E, dark: 0xE1C887)
    static let sprout = Color.adaptive(light: 0x8DBA8A, dark: 0xA8D69F)
    static let ink = Color.adaptive(light: 0x34413D, dark: 0xEFF4F0)
    static let secondaryInk = Color.adaptive(light: 0x61716B, dark: 0xBECCC6)
    static let card = Color.adaptive(light: 0xFFFDF8, dark: 0x1C2B26)
    static let quietFill = Color.adaptive(light: 0xEAF1EA, dark: 0x253B34)

    static func displayFont(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        .custom("Songti SC", size: size, relativeTo: style)
    }

    static func bodyFont(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .default)
    }
}

extension Color {
    static func adaptive(light: UInt, dark: UInt) -> Color {
        Color(uiColor: UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
