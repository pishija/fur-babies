import SwiftUI

struct FBDivider: View {
    var label: String? = nil

    var body: some View {
        if let label {
            HStack(spacing: Theme.Spacing.md) {
                line
                Text(label)
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Theme.Colors.textTertiary)
                line
            }
        } else {
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Theme.Colors.border)
            .frame(height: 1)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        FBDivider()
        FBDivider(label: "or")
        FBDivider(label: "continue with")
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
