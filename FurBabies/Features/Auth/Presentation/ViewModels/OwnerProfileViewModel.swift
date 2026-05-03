import Foundation

@MainActor
final class OwnerProfileViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var city = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var onComplete: (() -> Void)?

    private let user: AuthUser
    private let authService: AuthServiceProtocol

    var canContinue: Bool { !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(user: AuthUser, authService: AuthServiceProtocol) {
        self.user = user
        self.authService = authService
    }

    func save() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        // Firestore write will be wired here: users/{user.id} with name, city, createdAt
        // Stubbed until Firestore repositories are implemented
        try? await Task.sleep(for: .milliseconds(300))
        onComplete?()
    }
}
