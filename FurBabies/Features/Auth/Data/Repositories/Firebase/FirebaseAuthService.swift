import Foundation
import FirebaseAuth
import os

final class FirebaseAuthService: AuthServiceProtocol {

    var currentUser: AuthUser? {
        Auth.auth().currentUser.map(mapUser)
    }

    var authStateStream: AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                let uid = user?.uid ?? "nil"
                AppLogger.auth.debug("authStateStream emitted uid=\(uid)")
                continuation.yield(user.map { AuthUser(id: $0.uid, email: $0.email, displayName: $0.displayName) })
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    func signInWithApple(credential: AppleCredential) async throws -> AuthUser {
        AppLogger.auth.debug("signInWithApple — start")
        guard let tokenString = String(data: credential.identityToken, encoding: .utf8) else {
            AppLogger.auth.error("signInWithApple — invalid identity token data")
            throw AuthError.unknown(NSError(domain: "FirebaseAuthService", code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Invalid Apple identity token"]))
        }
        let oauthCredential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: credential.nonce,
            fullName: nil
        )
        return try await perform(label: "signInWithApple") {
            let result = try await Auth.auth().signIn(with: oauthCredential)
            if let fullName = credential.fullName, !fullName.isEmpty,
               (result.user.displayName ?? "").isEmpty {
                let req = result.user.createProfileChangeRequest()
                req.displayName = fullName
                try? await req.commitChanges()
            }
            var user = self.mapUser(result.user)
            user.isNewUser = result.additionalUserInfo?.isNewUser ?? false
            AppLogger.auth.info("signInWithApple — success uid=\(user.id) isNew=\(user.isNewUser)")
            return user
        }
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        AppLogger.auth.debug("signInWithEmail — start email=\(email)")
        return try await perform(label: "signInWithEmail") {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = self.mapUser(result.user)
            AppLogger.auth.info("signInWithEmail — success uid=\(user.id)")
            return user
        }
    }

    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        AppLogger.auth.debug("signUpWithEmail — start email=\(email)")
        return try await perform(label: "signUpWithEmail") {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            var user = self.mapUser(result.user)
            user.isNewUser = true
            AppLogger.auth.info("signUpWithEmail — success uid=\(user.id)")
            return user
        }
    }

    func sendPasswordReset(email: String) async throws {
        AppLogger.auth.debug("sendPasswordReset — email=\(email)")
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            AppLogger.auth.info("sendPasswordReset — sent")
        } catch {
            let mapped = mapError(error)
            AppLogger.auth.error("sendPasswordReset — error: \(mapped.errorDescription ?? error.localizedDescription)")
            throw mapped
        }
    }

    func signOut() throws {
        AppLogger.auth.debug("signOut — start")
        do {
            try Auth.auth().signOut()
            AppLogger.auth.info("signOut — success")
        } catch {
            let mapped = mapError(error)
            AppLogger.auth.error("signOut — error: \(mapped.errorDescription ?? error.localizedDescription)")
            throw mapped
        }
    }

    func deleteAccount() async throws {
        AppLogger.auth.debug("deleteAccount — start")
        guard let user = Auth.auth().currentUser else {
            AppLogger.auth.warning("deleteAccount — no current user")
            return
        }
        do {
            try await user.delete()
            AppLogger.auth.info("deleteAccount — success")
        } catch {
            let mapped = mapError(error)
            AppLogger.auth.error("deleteAccount — error: \(mapped.errorDescription ?? error.localizedDescription)")
            throw mapped
        }
    }

    // MARK: - Helpers

    private func perform<T>(label: String, _ block: () async throws -> T) async throws -> T {
        do {
            return try await block()
        } catch let error as AuthError {
            throw error
        } catch {
            let mapped = mapError(error)
            AppLogger.auth.error("\(label) — firebase error: \(error.localizedDescription) → mapped: \(mapped.errorDescription ?? "")")
            throw mapped
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
