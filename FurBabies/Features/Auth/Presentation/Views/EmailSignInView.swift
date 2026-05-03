import SwiftUI

struct EmailSignInView: View {
    let authService: AuthServiceProtocol
    var onResult: ((AuthResult) -> Void)?
    var onForgotPassword: ((String) -> Void)?
    var onSignUp: (() -> Void)?

    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        authService: AuthServiceProtocol,
        onResult: ((AuthResult) -> Void)? = nil,
        onForgotPassword: ((String) -> Void)? = nil,
        onSignUp: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.authService = authService
        self.onResult = onResult
        self.onForgotPassword = onForgotPassword
        self.onSignUp = onSignUp
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
        .onAppear { viewModel.onResult = onResult }
        .fbToast($viewModel.errorMessage, style: .error)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            backButton

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Sign in with email")
                    .font(Theme.Typography.title1)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Enter your email and password to continue")
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

                VStack(spacing: Theme.Spacing.sm) {
                    FBSecureField(
                        label: "Password",
                        placeholder: "Enter your password",
                        text: $viewModel.password,
                        submitLabel: .done,
                        onSubmit: { Task { await viewModel.continueWithEmail() } }
                    )
                    .disabled(viewModel.isLoading)

                    HStack {
                        Spacer()
                        Button {
                            onForgotPassword?(viewModel.email)
                        } label: {
                            Text("Forgot password?")
                                .font(Theme.Typography.footnote)
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.Colors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
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
            Text("Don't have an account?")
                .foregroundStyle(Theme.Colors.textSecondary)
            Button(action: { onSignUp?() }) {
                Text("Sign up")
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
        EmailSignInView(authService: FirebaseAuthService())
    }
}
