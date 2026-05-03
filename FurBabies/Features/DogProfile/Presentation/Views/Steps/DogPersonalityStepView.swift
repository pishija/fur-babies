import SwiftUI

struct DogPersonalityStepView: View {
    @ObservedObject var viewModel: CreateDogViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header

                LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                    ForEach(TemperamentTag.allCases, id: \.self) { tag in
                        tagChip(tag)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("What's \(viewModel.name.isEmpty ? "their" : viewModel.name + "'s") personality?")
                .font(Theme.Typography.title1)
                .foregroundStyle(Theme.Colors.textPrimary)
            Text("Select all that apply. This helps match with compatible dogs.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }

    private func tagChip(_ tag: TemperamentTag) -> some View {
        let isSelected = viewModel.temperamentTags.contains(tag)
        return Button {
            if isSelected {
                viewModel.temperamentTags.remove(tag)
            } else {
                viewModel.temperamentTags.insert(tag)
            }
        } label: {
            Text(tag.displayName)
                .font(Theme.Typography.subheading)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.lg)
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

#Preview {
    CreateDogFlowView(userId: "preview")
}
