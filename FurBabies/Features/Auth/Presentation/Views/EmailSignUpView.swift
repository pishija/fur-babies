import SwiftUI

struct EmailSignUpView: View {
    let authService: AuthServiceProtocol
    var onResult: ((AuthResult) -> Void)?
    var onSignIn: (() -> Void)?

    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        authService: AuthServiceProtocol,
        onResult: ((AuthResult) -> Void)? = nil,
        onSignIn: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.authService = authService
        self.onResult = onResult
        self.onSignIn = onSignIn
    }

    var body: some View {
        VStack {
            content
                .frame(maxHeight: .infinity, alignment: .top)

            bottomLink
                .padding(.bottom, Theme.Spacing.xl)
        }
        .padding([.horizontal, .top], Theme.Spacing.xl)
        .background(Theme.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.mode = .signUp
            viewModel.onResult = onResult
        }
        .fbToast($viewModel.errorMessage, style: .error)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            backButton

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Sign up with email")
                    .font(Theme.Typography.title1)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Create your account to get started")
                    .font(Theme.Typography.subheading)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            VStack(spacing: Theme.Spacing.xl) {
                FBTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $viewModel.email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    autocapitalization: .never,
                    submitLabel: .next
                )
                .disabled(viewModel.isLoading)

                FBSecureField(
                    label: "Password",
                    placeholder: "Enter your password",
                    text: $viewModel.password,
                    submitLabel: .next
                )
                .disabled(viewModel.isLoading)

                FBSecureField(
                    label: "Confirm Password",
                    placeholder: "Confirm your password",
                    text: $viewModel.confirmPassword,
                    submitLabel: .done,
                    onSubmit: { Task { await viewModel.continueWithEmail() } }
                )
                .disabled(viewModel.isLoading)
            }

            FBButton(
                title: "Continue",
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.canContinue,
                action: { Task { await viewModel.continueWithEmail() } }
            )
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text("Back")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Theme.Colors.primary)
        }
        .buttonStyle(.plain)
    }

    private var bottomLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(Theme.Colors.textSecondary)
            Button(action: { onSignIn?() }) {
                Text("Sign in")
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .buttonStyle(.plain)
        }
        .font(Theme.Typography.footnote)
    }
}

#Preview {
    NavigationStack {
        EmailSignUpView(authService: FirebaseAuthService())
    }
}
