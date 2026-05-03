import SwiftUI

struct FBButton: View {
    let title: String
    var style: Style = .primary
    var size: Size = .regular
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    enum Style { case primary, secondary, ghost, destructive }
    enum Size { case small, regular, large }

    var body: some View {
        Button(action: action) {
            ZStack {
                label.opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .controlSize(.small)
                }
            }
            .frame(maxWidth: style == .ghost ? nil : .infinity)
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
            .background(background)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: Theme.Radius.lg)
                        .strokeBorder(Theme.Colors.primary, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .opacity(!isEnabled && !isLoading ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
    }

    private var label: some View {
        Text(title)
            .font(size == .small ? Theme.Typography.subheading : Theme.Typography.headline)
            .fontWeight(.semibold)
    }

    private var height: CGFloat {
        switch size {
        case .small:   return 36
        case .regular: return 52
        case .large:   return 56
        }
    }

    private var horizontalPadding: CGFloat {
        size == .small ? Theme.Spacing.md : Theme.Spacing.lg
    }

    private var background: Color {
        switch style {
        case .primary:     return Theme.Colors.primary
        case .secondary:   return .clear
        case .ghost:       return .clear
        case .destructive: return Theme.Colors.error
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return Theme.Colors.textOnBrand
        case .secondary:   return Theme.Colors.primary
        case .ghost:       return Theme.Colors.textSecondary
        case .destructive: return Theme.Colors.textInverse
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        FBButton(title: "Get Started", action: {})
        FBButton(title: "Sign in with Email", style: .secondary, action: {})
        FBButton(title: "Cancel", style: .ghost, action: {})
        FBButton(title: "Delete Account", style: .destructive, action: {})
        FBButton(title: "Loading…", isLoading: true, action: {})
        FBButton(title: "Disabled", isEnabled: false, action: {})
        FBButton(title: "Small", size: .small, action: {})
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
