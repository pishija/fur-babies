import Foundation

struct AuthUser: Identifiable, Sendable {
    let id: String
    let email: String?
    let displayName: String?
}
