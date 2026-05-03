import SwiftUI

struct DogProfileView: View {
    @StateObject private var viewModel = DogProfileViewModel()
    @EnvironmentObject private var activeDogStore: ActiveDogStore
    @StateObject private var authService = AuthServiceHolder()

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let dog = viewModel.dog {
                profileContent(dog)
            } else if viewModel.errorMessage != nil {
                errorView
            } else {
                emptyView
            }
        }
        .navigationBarHidden(true)
        .task(id: activeDogStore.activeDogId) {
            await loadActiveDog()
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.Colors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private var emptyView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "pawprint.circle")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.textTertiary)
            Text("No dog selected")
                .font(Theme.Typography.title3)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private var errorView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.error)
            Text("Couldn't load profile")
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.textPrimary)
            FBButton(title: "Retry", style: .secondary) {
                Task { await loadActiveDog() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .padding(.horizontal, Theme.Spacing.xxl)
    }

    // MARK: - Profile content

    private func profileContent(_ dog: DogProfile) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                profileHeader(dog)
                quickStatsCard(dog)
                if !dog.temperamentTags.isEmpty {
                    temperamentSection(dog)
                }
                photosSection
                documentsSection
                healthSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxxl)
        }
        .background(Theme.Colors.background)
    }

    private func profileHeader(_ dog: DogProfile) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.muted)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Circle()
                            .strokeBorder(Theme.Colors.primary, lineWidth: 3)
                            .padding(-3)
                    }

                if let urlString = dog.primaryPhotoUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().tint(Theme.Colors.primary)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }

            VStack(spacing: Theme.Spacing.xxs) {
                Text(dog.name)
                    .font(Theme.Typography.title1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text("\(dog.breed) · \(dog.age)")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            if !dog.isPublic {
                Label("Private", systemImage: "lock.fill")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func quickStatsCard(_ dog: DogProfile) -> some View {
        FBCard {
            VStack(spacing: 0) {
                statRow(
                    label: "Sex",
                    value: "\(dog.sex.displayName)\(dog.isNeutered ? " · \(dog.sex.neuteredLabel)" : "")"
                )
                FBDivider()
                statRow(label: "Weight", value: String(format: "%.1f kg", dog.weightKg))
                FBDivider()
                statRow(label: "Size", value: dog.sizeClass.displayName)
                FBDivider()
                statRow(
                    label: "Birthday",
                    value: dog.birthday.formatted(date: .abbreviated, time: .omitted)
                )
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.body)
                .fontWeight(.medium)
                .foregroundStyle(Theme.Colors.primary)
        }
        .frame(height: 52)
    }

    private func temperamentSection(_ dog: DogProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Personality")
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.textPrimary)

            FlowLayout(spacing: Theme.Spacing.xs) {
                ForEach(dog.temperamentTags, id: \.self) { tag in
                    FBChip(label: tag.displayName, isSelected: true, onTap: {})
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var photosSection: some View {
        FBCard(padding: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Photos")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text("Coming soon")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var documentsSection: some View {
        FBCard {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Documents")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Health records, pedigree, insurance")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
    }

    private var healthSection: some View {
        FBCard {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Health Calendar")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Upcoming reminders and events")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Helpers

    private func loadActiveDog() async {
        guard let dogId = activeDogStore.activeDogId,
              let userId = DIContainer.shared.authService.currentUser?.id else { return }
        await viewModel.load(dogId: dogId, userId: userId)
    }
}

// Simple flowing layout for chips
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// Hold a reference to authService without importing Firebase in the view
@MainActor
private final class AuthServiceHolder: ObservableObject {
    let service = DIContainer.shared.authService
}

#Preview {
    DogProfileView()
        .environmentObject(ActiveDogStore.shared)
}
