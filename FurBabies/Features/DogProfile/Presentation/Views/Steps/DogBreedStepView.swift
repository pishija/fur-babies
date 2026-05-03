import SwiftUI

struct DogBreedStepView: View {
    @ObservedObject var viewModel: CreateDogViewModel

    private var suggestions: [String] {
        BreedList.suggestions(for: viewModel.breedSearch)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.top, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.md)

            searchField
                .padding(.horizontal, Theme.Spacing.xxl)

            if let error = viewModel.breedError {
                Text(error)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.top, Theme.Spacing.xxs)
            }

            breedGrid
                .padding(.top, Theme.Spacing.md)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("What breed is your dog?")
                .font(Theme.Typography.title1)
                .foregroundStyle(Theme.Colors.textPrimary)
            Text("Tap a breed or type your own below.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.Colors.textTertiary)
            TextField("Search breeds…", text: $viewModel.breedSearch)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .onChange(of: viewModel.breedSearch) { _, new in
                    viewModel.breed = new
                }
        }
        .frame(height: 48)
        .padding(.horizontal, Theme.Spacing.md)
        .background(Theme.Colors.muted)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .strokeBorder(Theme.Colors.border, lineWidth: 1)
        }
    }

    private var breedGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: Theme.Spacing.sm
            ) {
                ForEach(suggestions, id: \.self) { breed in
                    breedChip(breed)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private func breedChip(_ breed: String) -> some View {
        let isSelected = viewModel.breed == breed
        return Button {
            viewModel.breed = breed
            viewModel.breedSearch = breed
        } label: {
            Text(breed)
                .font(Theme.Typography.subheading)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
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

#Preview {
    CreateDogFlowView(userId: "preview")
}
