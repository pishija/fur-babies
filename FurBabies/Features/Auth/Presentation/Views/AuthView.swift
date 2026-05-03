import SwiftUI
import AuthenticationServices

struct AuthLandingView: View {
    let authService: AuthServiceProtocol
    var onResult: ((AuthResult) -> Void)?
    var onContinueWithEmail: (() -> Void)?

    @StateObject private var viewModel: AuthViewModel

    init(
        authService: AuthServiceProtocol,
        onResult: ((AuthResult) -> Void)? = nil,
        onContinueWithEmail: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.authService = authService
        self.onResult = onResult
        self.onContinueWithEmail = onContinueWithEmail
    }

    var body: some View {
        VStack(spacing: 20) {
            logoArea

            SignInWithAppleButton(
                .signIn,
                onRequest: { viewModel.prepareAppleRequest($0) },
                onCompletion: { result in
                    Task { await viewModel.handleAppleResult(result) }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .disabled(viewModel.isLoading)

            Text("By continuing, you agree to our Terms & Privacy Policy")
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Colors.textTertiary)
                .multilineTextAlignment(.center)

            emailButton
        }
        .padding(Theme.Spacing.xl)
        .frame(maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.onResult = onResult }
        .fbToast($viewModel.errorMessage, style: .error)
    }

    private var logoArea: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary)
                    .frame(width: 72, height: 72)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.Colors.textOnBrand)
            }

            Text("FurBabies")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(Theme.Colors.textPrimary)

            Text("Your dog's complete companion")
                .font(Theme.Typography.subheading)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(.vertical, Theme.Spacing.lg)
    }

    private var emailButton: some View {
        VStack(spacing: Theme.Spacing.md) {
            Button(action: { onContinueWithEmail?() }) {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "envelope")
                        .font(.system(size: 17, weight: .medium))
                    Text("Continue with email")
                        .font(Theme.Typography.headline)
                }
                .foregroundStyle(Theme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.lg)
                        .strokeBorder(Theme.Colors.border, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Text("Your data is safe and private.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textTertiary)
        }
    }
}

#Preview {
    AuthLandingView(authService: FirebaseAuthService())
}
