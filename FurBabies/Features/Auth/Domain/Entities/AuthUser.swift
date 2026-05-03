import Foundation

struct AuthUser: Identifiable, Sendable {
    let id: String
    let email: String?
    let displayName: String?
    // Transient — only meaningful immediately after auth, not stored anywhere
    var isNewUser: Bool = false
}
