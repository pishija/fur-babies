import SwiftUI

private enum AuthNavRoute: Hashable {
    case emailSignIn
    case emailSignUp
    case forgotPassword(prefillEmail: String)
}

struct AuthFlowView: View {
    var onAuthComplete: (() -> Void)?

    @State private var showingAuth = false
    @State private var path: [AuthNavRoute] = []
    @State private var pendingSetupUser: AuthUser? = nil

    private let authService: AuthServiceProtocol = FirebaseAuthService()

    var body: some View {
        ZStack {
            if showingAuth {
                authStack
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                OnboardingView(onComplete: { withAnimation(.easeInOut(duration: 0.4)) { showingAuth = true } })
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showingAuth)
    }

    private var authStack: some View {
        NavigationStack(path: $path) {
            AuthLandingView(
                authService: authService,
                onResult: handleResult,
                onContinueWithEmail: { path.append(.emailSignIn) }
            )
            .navigationDestination(for: AuthNavRoute.self) { route in
                switch route {
                case .emailSignIn:
                    EmailSignInView(
                        authService: authService,
                        onResult: handleResult,
                        onForgotPassword: { email in path.append(.forgotPassword(prefillEmail: email)) },
                        onSignUp: { path.append(.emailSignUp) }
                    )
                case .emailSignUp:
                    EmailSignUpView(
                        authService: authService,
                        onResult: handleResult,
                        onSignIn: { path.removeLast() }
                    )
                case .forgotPassword(let email):
                    ForgotPasswordView(prefillEmail: email, authService: authService)
                }
            }
        }
        .fullScreenCover(item: $pendingSetupUser) { user in
            OwnerProfileSetupView(
                user: user,
                authService: authService,
                onComplete: {
                    pendingSetupUser = nil
                    onAuthComplete?()
                }
            )
        }
    }

    private func handleResult(_ result: AuthResult) {
        switch result {
        case .authenticated:
            onAuthComplete?()
        case .needsProfileSetup(let user):
            pendingSetupUser = user
        }
    }
}

#Preview {
    AuthFlowView()
}
