import Foundation

struct AppleCredential: Sendable {
    let identityToken: Data
    let authorizationCode: Data
    let userId: String
    let email: String?
    let fullName: String?
    let nonce: String
}
