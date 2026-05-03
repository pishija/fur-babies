import Foundation

protocol AuthServiceProtocol: AnyObject {
    var currentUser: AuthUser? { get }
    var authStateStream: AsyncStream<AuthUser?> { get }

    func signInWithApple(credential: AppleCredential) async throws -> AuthUser
    func signInWithEmail(email: String, password: String) async throws -> AuthUser
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func deleteAccount() async throws
}
