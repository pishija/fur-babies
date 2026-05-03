import Foundation

@MainActor
final class CreateDogViewModel: ObservableObject {
    let userId: String

    @Published var currentStep = 1

    // Step 1 — name
    @Published var name = ""
    @Published var nameError: String? = nil

    // Step 2 — breed
    @Published var breed = ""
    @Published var breedSearch = ""
    @Published var breedError: String? = nil

    // Step 3 — sex, birthday, weight
    @Published var sex: DogSex? = nil
    @Published var birthday: Date = Calendar.current.date(byAdding: .year, value: -2, to: .now) ?? .now
    @Published var weightText = ""
    @Published var sexError: String? = nil
    @Published var birthdayError: String? = nil
    @Published var weightError: String? = nil

    // Step 4 — temperament (optional)
    @Published var temperamentTags: Set<TemperamentTag> = []

    // Step 5 — extras
    @Published var sizeClass: DogSizeClass = .medium
    @Published var coatColour = ""
    @Published var microchip = ""
    @Published var isNeutered = false
    @Published var isPublic = true

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let createDogUseCase: CreateDogUseCase

    init(userId: String, createDogUseCase: CreateDogUseCase? = nil) {
        self.userId = userId
        self.createDogUseCase = createDogUseCase ?? DIContainer.shared.createDogUseCase
    }

    var canAdvance: Bool {
        switch currentStep {
        case 1:
            return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2:
            return !breed.trimmingCharacters(in: .whitespaces).isEmpty
        case 3:
            guard sex != nil else { return false }
            guard let w = Double(weightText), w >= 0.1, w <= 200 else { return false }
            return birthday < .now
        default:
            return true
        }
    }

    func advance() {
        guard validate() else { return }
        if currentStep == 3, let w = Double(weightText) {
            sizeClass = DogSizeClass.suggested(forWeightKg: w)
        }
        if currentStep < 5 {
            currentStep += 1
        }
    }

    func goBack() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }

    func createDog() async -> String? {
        guard validate() else { return nil }
        isLoading = true
        defer { isLoading = false }

        let weightKg = Double(weightText) ?? 1.0
        let dog = DogProfile(
            id: "",
            userId: userId,
            name: name.trimmingCharacters(in: .whitespaces),
            breed: breed.trimmingCharacters(in: .whitespaces),
            sex: sex ?? .male,
            birthday: birthday,
            weightKg: weightKg,
            sizeClass: sizeClass,
            coatColour: coatColour.trimmingCharacters(in: .whitespaces),
            microchip: microchip.trimmingCharacters(in: .whitespaces),
            isNeutered: isNeutered,
            isPublic: isPublic,
            temperamentTags: Array(temperamentTags),
            primaryPhotoUrl: nil,
            createdAt: .now,
            updatedAt: .now
        )

        do {
            let dogId = try await createDogUseCase.execute(dog)
            AppLogger.dog.info("createDog — success id=\(dogId)")
            return dogId
        } catch {
            AppLogger.dog.error("createDog — failed: \(error)")
            errorMessage = "Couldn't save your dog's profile. Please try again."
            return nil
        }
    }

    private func validate() -> Bool {
        switch currentStep {
        case 1:
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { nameError = "Name is required"; return false }
            if trimmed.count > 50 { nameError = "Name must be 50 characters or fewer"; return false }
            nameError = nil
        case 2:
            if breed.trimmingCharacters(in: .whitespaces).isEmpty { breedError = "Breed is required"; return false }
            breedError = nil
        case 3:
            if sex == nil { sexError = "Please select a sex"; return false }
            sexError = nil
            if birthday >= .now { birthdayError = "Birthday must be in the past"; return false }
            let thirtyYearsAgo = Calendar.current.date(byAdding: .year, value: -30, to: .now) ?? .distantPast
            if birthday < thirtyYearsAgo { birthdayError = "Birthday can't be more than 30 years ago"; return false }
            birthdayError = nil
            guard let w = Double(weightText), w >= 0.1, w <= 200 else {
                weightError = "Enter a valid weight between 0.1 and 200 kg"
                return false
            }
            weightError = nil
        default:
            break
        }
        return true
    }
}
