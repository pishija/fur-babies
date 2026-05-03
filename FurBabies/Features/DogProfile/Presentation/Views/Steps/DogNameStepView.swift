import SwiftUI

struct DogNameStepView: View {
    @ObservedObject var viewModel: CreateDogViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                dogPhotoPlaceholder

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("What's your dog's name?")
                        .font(Theme.Typography.title1)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("This is how your dog will appear everywhere in the app.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FBTextField(
                    label: "Dog's name",
                    placeholder: "e.g. Buddy",
                    text: $viewModel.name,
                    errorMessage: viewModel.nameError,
                    autocapitalization: .words,
                    submitLabel: .next
                )
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private var dogPhotoPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.muted)
                .frame(width: 120, height: 120)
                .overlay {
                    Circle()
                        .strokeBorder(Theme.Colors.borderStrong, lineWidth: 2)
                }
            Image(systemName: "pawprint.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Colors.textTertiary)
        }
    }
}

#Preview {
    CreateDogFlowView(userId: "preview")
}
