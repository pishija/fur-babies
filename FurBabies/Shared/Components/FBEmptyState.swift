import SwiftUI

struct FBEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(Theme.Colors.textTertiary)

            VStack(spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let title = actionTitle, let action {
                FBButton(title: title, action: action)
                    .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xxxl) {
        FBEmptyState(
            systemImage: "pawprint",
            title: "No dogs yet",
            message: "Add your first dog to get started.",
            actionTitle: "Add a Dog",
            action: {}
        )
        FBEmptyState(
            systemImage: "heart.slash",
            title: "No matches yet",
            message: "Keep swiping to find your dog's new friends."
        )
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
