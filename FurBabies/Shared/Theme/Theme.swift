import SwiftUI

enum Theme {
    enum Colors {
        static let primary    = GeneratedTokens.Color.brandPrimary
        static let secondary  = GeneratedTokens.Color.brandSecondary
        static let accent     = GeneratedTokens.Color.brandAccent

        static let background = GeneratedTokens.Color.backgroundDefault
        static let surface    = GeneratedTokens.Color.backgroundSurface
        static let muted      = GeneratedTokens.Color.backgroundMuted

        static let textPrimary   = GeneratedTokens.Color.textPrimary
        static let textSecondary = GeneratedTokens.Color.textSecondary
        static let textTertiary  = GeneratedTokens.Color.textTertiary
        static let textInverse   = GeneratedTokens.Color.textInverse
        static let textOnBrand   = GeneratedTokens.Color.textOnBrand

        static let border       = GeneratedTokens.Color.borderDefault
        static let borderStrong = GeneratedTokens.Color.borderStrong

        static let error   = GeneratedTokens.Color.statusError
        static let success = GeneratedTokens.Color.statusSuccess
        static let warning = GeneratedTokens.Color.statusWarning
        static let info    = GeneratedTokens.Color.statusInfo
    }

    enum Typography {
        static let largeTitle = Font.system(size: GeneratedTokens.FontSize.largeTitle, weight: .bold)
        static let title1     = Font.system(size: GeneratedTokens.FontSize.title1,     weight: .bold)
        static let title2     = Font.system(size: GeneratedTokens.FontSize.title2,     weight: .semibold)
        static let title3     = Font.system(size: GeneratedTokens.FontSize.title3,     weight: .semibold)
        static let headline   = Font.system(size: GeneratedTokens.FontSize.headline,   weight: .semibold)
        static let body       = Font.system(size: GeneratedTokens.FontSize.body,       weight: .regular)
        static let callout    = Font.system(size: GeneratedTokens.FontSize.callout,    weight: .regular)
        static let subheading = Font.system(size: GeneratedTokens.FontSize.subheading, weight: .regular)
        static let footnote   = Font.system(size: GeneratedTokens.FontSize.footnote,   weight: .regular)
        static let caption    = Font.system(size: GeneratedTokens.FontSize.caption,    weight: .regular)
    }

    enum Spacing {
        static let xxs  = GeneratedTokens.Spacing.xxs
        static let xs   = GeneratedTokens.Spacing.xs
        static let sm   = GeneratedTokens.Spacing.sm
        static let md   = GeneratedTokens.Spacing.md
        static let lg   = GeneratedTokens.Spacing.lg
        static let xl   = GeneratedTokens.Spacing.xl
        static let xxl  = GeneratedTokens.Spacing.xxl
        static let xxxl = GeneratedTokens.Spacing.xxxl
    }

    enum Radius {
        static let sm   = GeneratedTokens.Radius.sm
        static let md   = GeneratedTokens.Radius.md
        static let lg   = GeneratedTokens.Radius.lg
        static let xl   = GeneratedTokens.Radius.xl
        static let full = GeneratedTokens.Radius.full
    }
}
