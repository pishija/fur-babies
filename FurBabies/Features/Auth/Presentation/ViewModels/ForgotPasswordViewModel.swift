import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSendReset = false

    private let authService: AuthServiceProtocol

    var canSend: Bool { !email.isEmpty }

    init(prefillEmail: String = "", authService: AuthServiceProtocol) {
        self.email = prefillEmail
        self.authService = authService
    }

    func sendResetLink() async {
        errorMessage = nil
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.contains("@"), trimmed.contains(".") else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.sendPasswordReset(email: trimmed)
            didSendReset = true
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
