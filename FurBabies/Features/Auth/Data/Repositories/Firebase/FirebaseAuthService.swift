import Foundation
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol {

    var currentUser: AuthUser? {
        Auth.auth().currentUser.map(mapUser)
    }

    var authStateStream: AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user.map { AuthUser(id: $0.uid, email: $0.email, displayName: $0.displayName) })
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    func signInWithApple(credential: AppleCredential) async throws -> AuthUser {
        guard let tokenString = String(data: credential.identityToken, encoding: .utf8) else {
            throw AuthError.unknown(NSError(domain: "FirebaseAuthService", code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Invalid Apple identity token"]))
        }
        let oauthCredential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: credential.nonce,
            fullName: nil
        )
        return try await perform {
            let result = try await Auth.auth().signIn(with: oauthCredential)
            if let fullName = credential.fullName, !fullName.isEmpty,
               (result.user.displayName ?? "").isEmpty {
                let req = result.user.createProfileChangeRequest()
                req.displayName = fullName
                try? await req.commitChanges()
            }
            var user = self.mapUser(result.user)
            user.isNewUser = result.additionalUserInfo?.isNewUser ?? false
            return user
        }
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        try await perform {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return self.mapUser(result.user)
        }
    }

    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        try await perform {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            var user = self.mapUser(result.user)
            user.isNewUser = true
            return user
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapError(error)
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw mapError(error)
        }
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Helpers

    private func perform<T>(_ block: () async throws -> T) async throws -> T {
        do {
            return try await block()
        } catch let error as AuthError {
            throw error
        } catch {
            throw mapError(error)
        }
    }

    private func mapUser(_ user: User) -> AuthUser {
        AuthUser(id: user.uid, email: user.email, displayName: user.displayName)
    }

    private func mapError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else { return .unknown(error) }
        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:                          return .invalidEmail
        case .weakPassword:                          return .weakPassword
        case .userNotFound:                          return .userNotFound
        case .wrongPassword:                         return .wrongPassword
        case .emailAlreadyInUse:                     return .emailAlreadyInUse
        case .accountExistsWithDifferentCredential:  return .accountExistsWithDifferentCredential
        default:                                     return .unknown(error)
        }
    }
}
