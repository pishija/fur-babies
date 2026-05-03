import SwiftUI

struct OwnerProfileSetupView: View {
    @StateObject private var viewModel: OwnerProfileViewModel

    init(user: AuthUser, authService: AuthServiceProtocol, onComplete: (() -> Void)? = nil) {
        let vm = OwnerProfileViewModel(user: user, authService: authService)
        vm.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        VStack {
            topSection
                .frame(maxHeight: .infinity, alignment: .top)

            FBButton(
                title: "Continue",
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.canContinue,
                action: { Task { await viewModel.save() } }
            )
            .padding(.bottom, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.xxl)
        .background(Theme.Colors.background.ignoresSafeArea())
        .fbToast($viewModel.errorMessage, style: .error)
    }

    private var topSection: some View {
        VStack(spacing: 28) {
            VStack(spacing: Theme.Spacing.sm) {
                Text("Tell us about yourself")
                    .font(Theme.Typography.title1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Just a couple details so we can\npersonalise your experience")
                    .font(Theme.Typography.subheading)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.Colors.primary)

            VStack(spacing: Theme.Spacing.lg) {
                FBTextField(
                    label: "First Name",
                    placeholder: "Enter your first name",
                    text: $viewModel.firstName,
                    submitLabel: .next
                )
                .disabled(viewModel.isLoading)

                FBTextField(
                    label: "City (optional)",
                    placeholder: "Where are you based?",
                    text: $viewModel.city,
                    submitLabel: .done,
                    onSubmit: { Task { await viewModel.save() } }
                )
                .disabled(viewModel.isLoading)
            }
        }
    }
}

#Preview {
    let user = AuthUser(id: "preview", email: "user@example.com", displayName: nil)
    OwnerProfileSetupView(user: user, authService: FirebaseAuthService())
}
