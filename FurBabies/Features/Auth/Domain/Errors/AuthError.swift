import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case passwordMismatch
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case accountExistsWithDifferentCredential
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 8 characters."
        case .passwordMismatch:
            return "Passwords don't match."
        case .userNotFound:
            return "No account found with that email."
        case .wrongPassword:
            return "Incorrect email or password."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .accountExistsWithDifferentCredential:
            return "This email is linked to Sign in with Apple. Use that instead."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
