import Foundation

final class FirebaseAuthService: AuthServiceProtocol {
    private(set) var currentUser: AuthUser? = nil

    var authStateStream: AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            continuation.yield(nil)
            continuation.finish()
        }
    }

    func signInWithApple(credential: AppleCredential) async throws -> AuthUser {
        throw AuthError.unknown(PlaceholderError.notImplemented)
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        throw AuthError.unknown(PlaceholderError.notImplemented)
    }

    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        throw AuthError.unknown(PlaceholderError.notImplemented)
    }

    func sendPasswordReset(email: String) async throws {
        throw AuthError.unknown(PlaceholderError.notImplemented)
    }

    func signOut() throws {}

    func deleteAccount() async throws {
        throw AuthError.unknown(PlaceholderError.notImplemented)
    }
}

private enum PlaceholderError: LocalizedError {
    case notImplemented
    var errorDescription: String? { "Firebase not configured yet." }
}
