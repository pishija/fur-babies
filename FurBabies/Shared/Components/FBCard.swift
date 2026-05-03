import SwiftUI

struct FBCard<Content: View>: View {
    var padding: CGFloat = Theme.Spacing.md
    let content: Content

    init(padding: CGFloat = Theme.Spacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Theme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        FBCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Buddy")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text("Golden Retriever · 3 years")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        FBCard(padding: 0) {
            Text("Zero padding card")
                .padding(Theme.Spacing.lg)
        }
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
