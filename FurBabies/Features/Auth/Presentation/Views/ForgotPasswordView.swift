import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    init(prefillEmail: String = "", authService: AuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: ForgotPasswordViewModel(prefillEmail: prefillEmail, authService: authService))
    }

    var body: some View {
        VStack {
            topContent
                .frame(maxHeight: .infinity, alignment: .top)

            bottomActions
                .padding(.bottom, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
        .background(Theme.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fbToast($viewModel.errorMessage, style: .error)
        .animation(.spring(duration: 0.3), value: viewModel.didSendReset)
    }

    private var topContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            backButton

            if viewModel.didSendReset {
                successState
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                formState
                    .transition(.opacity)
            }
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private var formState: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.sm) {
                Text("Reset Password")
                    .font(Theme.Typography.title1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Enter your email and we'll send you\na link to reset your password")
                    .font(Theme.Typography.subheading)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "key.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.Colors.secondary)

            FBTextField(
                label: "Email",
                placeholder: "you@example.com",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                submitLabel: .done,
                onSubmit: { Task { await viewModel.sendResetLink() } }
            )
            .disabled(viewModel.isLoading)
        }
    }

    private var successState: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "envelope.badge.checkmark.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.Colors.success)

                Text("Check your inbox")
                    .font(Theme.Typography.title2)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("We've sent a reset link to \(viewModel.email).")
                    .font(Theme.Typography.subheading)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var bottomActions: some View {
        VStack(spacing: Theme.Spacing.lg) {
            if !viewModel.didSendReset {
                FBButton(
                    title: "Send Reset Link",
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.canSend,
                    action: { Task { await viewModel.sendResetLink() } }
                )
            }

            Button(action: { dismiss() }) {
                Text("Remember your password? ")
                    .foregroundStyle(Theme.Colors.textSecondary)
                + Text("Sign in")
                    .foregroundStyle(Theme.Colors.primary)
            }
            .font(Theme.Typography.footnote)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView(prefillEmail: "user@example.com", authService: FirebaseAuthService())
    }
}
