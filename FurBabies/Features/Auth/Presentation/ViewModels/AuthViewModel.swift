import Foundation
import AuthenticationServices
import CryptoKit
import Security

enum AuthMode {
    case signIn, signUp
}

enum AuthResult {
    case authenticated(AuthUser)
    case needsProfileSetup(AuthUser)
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var mode: AuthMode = .signIn
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private(set) var currentNonce = ""

    var onResult: ((AuthResult) -> Void)?

    private let authService: AuthServiceProtocol

    var canContinue: Bool {
        !email.isEmpty && !password.isEmpty
    }

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        errorMessage = nil
        confirmPassword = ""
    }

    func continueWithEmail() async {
        errorMessage = nil
        guard validate() else { return }

        isLoading = true
        defer { isLoading = false }

        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if mode == .signIn {
                let user = try await authService.signInWithEmail(email: trimmed, password: password)
                onResult?(.authenticated(user))
            } else {
                let user = try await authService.signUpWithEmail(email: trimmed, password: password)
                onResult?(.needsProfileSetup(user))
            }
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        errorMessage = nil

        switch result {
        case .failure:
            return
        case .success(let authorization):
            guard
                let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityToken = appleCredential.identityToken,
                let authCode = appleCredential.authorizationCode
            else {
                errorMessage = "Sign in with Apple failed. Please try again."
                return
            }

            let formatter = PersonNameComponentsFormatter()
            let fullName = appleCredential.fullName.map { formatter.string(from: $0) }

            let credential = AppleCredential(
                identityToken: identityToken,
                authorizationCode: authCode,
                userId: appleCredential.user,
                email: appleCredential.email,
                fullName: fullName,
                nonce: currentNonce
            )

            isLoading = true
            defer { isLoading = false }

            do {
                let user = try await authService.signInWithApple(credential: credential)
                onResult?(user.isNewUser ? .needsProfileSetup(user) : .authenticated(user))
            } catch let authError as AuthError {
                errorMessage = authError.errorDescription
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func validate() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.contains("@"), trimmed.contains(".") else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return false
        }

        guard password.count >= 8 else {
            errorMessage = AuthError.weakPassword.errorDescription
            return false
        }

        if mode == .signUp, password != confirmPassword {
            errorMessage = AuthError.passwordMismatch.errorDescription
            return false
        }

        return true
    }

    private func randomNonce(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
