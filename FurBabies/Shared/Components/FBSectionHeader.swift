import SwiftUI

struct FBSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.textPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Theme.Typography.subheading)
                        .foregroundStyle(Theme.Colors.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        FBSectionHeader(title: "Recent Activity")
        FBSectionHeader(title: "Photos", actionTitle: "See all", action: {})
        FBSectionHeader(title: "Health Events", actionTitle: "Add", action: {})
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
