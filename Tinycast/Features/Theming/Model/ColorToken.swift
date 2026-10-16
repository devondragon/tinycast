import Foundation

/// Where a token's color comes from, so one alpha table serves every theme.
enum ColorRecipe: Equatable, Sendable {
    /// The theme's ink at an alpha per appearance: the ramp.
    case ink(dark: Double, light: Double)
    /// The theme's surface at an alpha per appearance: scrims, and ink drawn on solid ink.
    case surface(dark: Double, light: Double)
    case role(ThemeRole, dark: Double, light: Double)
    case fixed(RGBAPair)
    case system(SystemColor, dark: Double, light: Double)
}

/// One case per `Theme.Colors` token.
enum ColorToken: String, CaseIterable, Sendable {
    case panelScrim, dialogDimming, findMatch, findCurrent, findCurrentInk, tooltipShadow
    case selection, rowHover, emojiCell, emojiHoverBorder, emojiSelectionBorder, emojiInnerBorder
    case menuHover, separator, controlSurface, controlHover, controlPressed, border
    case textPrimary, textSecondary, textTertiary, menuSymbol, noteText, iconPlaceholder, sheen
    case cardFill, cardStroke
    case layoutPreviewWindow, layoutPreviewWindowSelected, layoutPreviewGround
    case roomPreviewDim, roomCardFill, roomCardStroke, roomCardShadow, roomCardDot
    case searchFlash, checkerLight, checkerDark, brand, dropGuide, dropGuideArmed
    case primaryAction, destructive, success, warning, composerSend, composerSendInk
    case windowSurface, dropTarget, progress, terminalSurface, accent, onAccent, link
    case chatText
    case syntaxKeyword, syntaxString, syntaxNumber, syntaxComment, syntaxType, syntaxFunction
    case syntaxConstant, syntaxAttribute, syntaxProperty, syntaxInserted, syntaxDeleted

    var baseRecipe: ColorRecipe {
        switch self {
        case .panelScrim: .surface(dark: 0.40, light: 0.55)
        case .dialogDimming: .fixed(.both(.gray(0, alpha: 0.34)))
        case .findMatch: .role(.highlight, dark: 0.32, light: 0.4)
        case .findCurrent: .role(.highlight, dark: 0.9, light: 0.95)
        case .findCurrentInk: .fixed(.both(.gray(0)))
        case .tooltipShadow: .fixed(.both(.gray(0, alpha: 0.18)))
        case .selection: .ink(dark: 0.10, light: 0.09)
        case .rowHover: .ink(dark: 0.05, light: 0.045)
        case .emojiCell: .ink(dark: 0.045, light: 0.04)
        case .emojiHoverBorder: .ink(dark: 0.42, light: 0.34)
        case .emojiSelectionBorder: .ink(dark: 0.92, light: 0.72)
        case .emojiInnerBorder: .surface(dark: 0.72, light: 0.72)
        case .menuHover: .ink(dark: 0.10, light: 0.09)
        case .separator: .ink(dark: 0.10, light: 0.12)
        case .controlSurface: .ink(dark: 0.10, light: 0.08)
        case .controlHover: .ink(dark: 0.16, light: 0.14)
        case .controlPressed: .ink(dark: 0.24, light: 0.20)
        case .border: .ink(dark: 0.20, light: 0.18)
        case .textPrimary: .ink(dark: 1.0, light: 1.0)
        case .textSecondary: .ink(dark: 0.60, light: 0.60)
        case .textTertiary: .ink(dark: 0.40, light: 0.42)
        case .menuSymbol: .ink(dark: 0.70, light: 0.70)
        case .noteText: .ink(dark: 0.90, light: 0.85)
        case .iconPlaceholder: .ink(dark: 0.06, light: 0.06)
        case .sheen: .ink(dark: 0.04, light: 0.04)
        case .cardFill: .ink(dark: 0.05, light: 0.04)
        case .cardStroke: .ink(dark: 0.10, light: 0.10)
        case .layoutPreviewWindow:
            .fixed(RGBAPair(dark: .gray(1, alpha: 0.22), light: .gray(1, alpha: 0.28)))
        case .layoutPreviewWindowSelected:
            .fixed(RGBAPair(dark: .gray(1, alpha: 0.38), light: .gray(1, alpha: 0.44)))
        case .layoutPreviewGround:
            .fixed(RGBAPair(dark: .gray(0, alpha: 0.55), light: .gray(0, alpha: 0.50)))
        case .roomPreviewDim: .fixed(.both(.gray(0, alpha: 0.18)))
        case .roomCardFill:
            .fixed(RGBAPair(dark: .gray(0.16, alpha: 0.94), light: .gray(0.98, alpha: 0.94)))
        case .roomCardStroke: .role(.accent, dark: 1, light: 1)
        case .roomCardShadow: .fixed(.both(.gray(0, alpha: 0.25)))
        case .roomCardDot: .ink(dark: 0.25, light: 0.25)
        case .searchFlash: .role(.accent, dark: 0.35, light: 0.35)
        case .checkerLight: .fixed(.both(.gray(1, alpha: 0.22)))
        case .checkerDark: .fixed(.both(.gray(0, alpha: 0.22)))
        case .brand: .fixed(.both(RGBA(0.525, 0.231, 1.0)))
        case .dropGuide: .ink(dark: 0.35, light: 0.35)
        case .dropGuideArmed, .primaryAction: .role(.primaryAction, dark: 1, light: 1)
        case .destructive: .role(.destructive, dark: 1, light: 1)
        case .success: .role(.success, dark: 1, light: 1)
        case .warning: .role(.warning, dark: 1, light: 1)
        case .composerSend: .ink(dark: 0.92, light: 0.92)
        case .composerSendInk: .surface(dark: 0.85, light: 1)
        case .windowSurface: .system(.windowBackground, dark: 1, light: 1)
        case .dropTarget, .accent: .role(.accent, dark: 1, light: 1)
        case .progress: .role(.progress, dark: 1, light: 1)
        case .terminalSurface: .fixed(RGBAPair(dark: .gray(0.07), light: .gray(0.99)))
        case .onAccent: .role(.onAccent, dark: 1, light: 1)
        case .link: .role(.link, dark: 1, light: 1)
        case .chatText: .system(.label, dark: 1, light: 1)
        case .syntaxKeyword: .fixed(.hex(dark: 0xFC5FA3, light: 0x9F3897))
        case .syntaxString: .fixed(.hex(dark: 0xFC6A5D, light: 0xBE2B19))
        case .syntaxNumber: .fixed(.hex(dark: 0xD0BF69, light: 0x272AD8))
        case .syntaxComment: .fixed(.hex(dark: 0x87939E, light: 0x576672))
        case .syntaxType: .fixed(.hex(dark: 0x5DD8FF, light: 0x1C6E78))
        case .syntaxFunction: .fixed(.hex(dark: 0x67B7A4, light: 0x2B6A72))
        case .syntaxConstant: .fixed(.hex(dark: 0xD0A8FF, light: 0x6C36A9))
        case .syntaxAttribute: .fixed(.hex(dark: 0xFD8F3F, light: 0x78492A))
        case .syntaxProperty: .fixed(.hex(dark: 0x6BBCDD, light: 0x0F68A0))
        case .syntaxInserted: .fixed(.hex(dark: 0x67D97E, light: 0x1C7234))
        case .syntaxDeleted: .fixed(.hex(dark: 0xFC6A5D, light: 0xBA2F1E))
        }
    }

    static let syntax: [ColorToken] = [
        .syntaxKeyword, .syntaxString, .syntaxNumber, .syntaxComment, .syntaxType, .syntaxFunction,
        .syntaxConstant, .syntaxAttribute, .syntaxProperty, .syntaxInserted, .syntaxDeleted,
    ]
}
