import SwiftUI

struct FBBadge: View {
    let label: String
    var style: Style = .neutral
    var icon: String? = nil

    enum Style {
        case primary, success, warning, error, neutral

        var backgroundColor: Color {
            switch self {
            case .primary: return Theme.Colors.primary.opacity(0.12)
            case .success: return Theme.Colors.success.opacity(0.12)
            case .warning: return Theme.Colors.warning.opacity(0.12)
            case .error:   return Theme.Colors.error.opacity(0.12)
            case .neutral: return Theme.Colors.muted
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return Theme.Colors.primary
            case .success: return Theme.Colors.success
            case .warning: return Theme.Colors.warning
            case .error:   return Theme.Colors.error
            case .neutral: return Theme.Colors.textSecondary
            }
        }
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(label)
                .font(Theme.Typography.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(style.foregroundColor)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, 4)
        .background(style.backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        HStack {
            FBBadge(label: "Vaccinated", style: .success, icon: "checkmark")
            FBBadge(label: "Large", style: .neutral)
            FBBadge(label: "Male", style: .primary)
        }
        HStack {
            FBBadge(label: "Overdue", style: .error, icon: "exclamationmark")
            FBBadge(label: "Due soon", style: .warning, icon: "clock")
        }
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
