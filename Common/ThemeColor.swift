import UIKit

private struct ColorPair {
    var light: UIColor
    var dark: UIColor

    var color: UIColor {
        .init(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .light, .unspecified: return self.light
            case .dark: return self.dark
            @unknown default: return self.light
            }
        })
    }
}

enum ThemeColor {
    static let background = ColorPair(light: .white, dark: .black).color
    static let keyboardBackground = ColorPair(
        light: .white,
        dark: UIColor(white: 0.1, alpha: 1.0)).color
    static let selectedBackground = ColorPair(
        light: UIColor(white: 0.9, alpha: 1.0),
        dark: UIColor(white: 0.2, alpha: 1.0)).color
    static let highlightedBackground = ColorPair(light: .gray, dark: .gray).color
    static let invertedText = background

    static let buttonBackground = ColorPair(light: .white, dark: .darkGray).color
    static let controlButtonBackground = ColorPair(
        light: .lightGray,
        dark: UIColor(white: 0.2, alpha: 1.0)).color
    static let buttonText = ColorPair(light: .black, dark: .white).color
    static let buttonTextOnFlickPopup = UIColor.black
    static let buttonTextDisabled = ColorPair(light: .gray, dark: .gray).color
    static let buttonSubText = ColorPair(
        light: .lightGray,
        dark: UIColor(white: 0.90, alpha: 1.0)).color
    static let buttonBorder = ColorPair(light: .gray, dark: keyboardBackground).color
    static let buttonHighlighted = ColorPair(
        light: UIColor(hue: 0.10, saturation: 0.07, brightness: 0.96, alpha: 1.0),
        dark: UIColor(hue: 0.10, saturation: 0.07, brightness: 0.7, alpha: 1.0)).color
    static let buttonSelected = ColorPair(
        light: UIColor(white: 0.95, alpha: 1.0),
        dark: UIColor(white: 0.6, alpha: 1.0)).color

    static let shadow = ColorPair(light: .black, dark: .clear).color

    static let sessionCellBorder = ColorPair(
        light: UIColor(white: 0.75, alpha: 1.0),
        dark: UIColor(white: 0.3, alpha: 1.0)).color

    static let hudBackground = ColorPair(
        light: UIColor(white: 0, alpha: 0.5),
        dark: UIColor(white: 1, alpha: 0.3)).color
    static let userInteractionMask = UIColor(white: 1, alpha: 0.2)
}
