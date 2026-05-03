import SwiftUI

struct FBChip: View {
    let label: String
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(Theme.Typography.subheading)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs)
                .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected ? Theme.Colors.primary : Theme.Colors.border,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct FBChipGroup: View {
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(options, id: \.self) { option in
                    FBChip(label: option, isSelected: selected.contains(option)) {
                        if selected.contains(option) {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = ["Friendly", "Playful"]
    let tags = ["Friendly", "Playful", "Calm", "Protective", "Trained", "Good with kids"]

    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        FBChipGroup(options: tags, selected: $selected)
    }
    .padding(.vertical, Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
